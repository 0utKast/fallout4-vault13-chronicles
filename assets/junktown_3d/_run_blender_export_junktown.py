
import math
import os
import sys
from collections import defaultdict, deque
import bpy
import bmesh
from mathutils import Vector

TEST_DIR = r"c:\proyectos_python\Mods_Fallout\tools_3d\test_meshes"
OUT_DIR = r"c:\proyectos_python\Mods_Fallout\cronicas_refugio_13\assets\junktown_3d\Meshes\V13Chronicles\Junktown"
PYNIFLY_DIR = r"C:\Users\educa\AppData\Roaming\Blender Foundation\Blender\5.2\scripts\addons\io_scene_nifly"

if PYNIFLY_DIR not in sys.path:
    sys.path.insert(0, PYNIFLY_DIR)
from pyn import pynifly


def clear_scene():
    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    for m in list(bpy.data.meshes):
        bpy.data.meshes.remove(m)
    for mat in list(bpy.data.materials):
        bpy.data.materials.remove(mat)


def assign_shader_on_material(mat, bgsm_path: str, diffuse_dds: str, normal_dds: str, spec_dds: str, env_dds: str = r"textures\Shared\Cubemaps\mipblur_DefaultOutside1.dds"):
    mat["BS_Shader_Block_Name"] = "BSLightingShaderProperty"
    mat["BSLSP_Shader_Name"] = bgsm_path
    mat["BSShaderTextureSet_Diffuse"] = diffuse_dds
    mat["BSShaderTextureSet_Normal"] = normal_dds
    mat["BSShaderTextureSet_Specular"] = spec_dds
    mat["BSShaderTextureSet_EnvMap"] = env_dds
    for k in ["NiAlphaProperty_flags", "NiAlphaProperty_threshold", "BSShaderTextureSet_EnvMapMask", "BSLSP_Shader_Type"]:
        if k in mat:
            del mat[k]
    if hasattr(mat, "pyn_shader"):
        mat.pyn_shader.Shader_Type = ""
    if mat.node_tree:
        for n in mat.node_tree.nodes:
            if n.bl_idname == "ShaderNodeTexImage":
                n.image = None
        bsdf = mat.node_tree.nodes.get("Principled BSDF")
        if bsdf and "Alpha" in bsdf.inputs:
            for l in list(bsdf.inputs["Alpha"].links):
                mat.node_tree.links.remove(l)
            bsdf.inputs["Alpha"].default_value = 1.0


def recompute_welded_normals(mesh_obj):
    bm = bmesh.new()
    bm.from_mesh(mesh_obj.data)
    bm.verts.ensure_lookup_table()
    bm.faces.ensure_lookup_table()
    bm.normal_update()

    pos_groups = defaultdict(list)
    vert_to_key = {}
    for v in bm.verts:
        k = (round(v.co.x, 3), round(v.co.y, 3), round(v.co.z, 3))
        pos_groups[k].append(v)
        vert_to_key[v.index] = k

    welded_n = {}
    for k, vlist in pos_groups.items():
        fn_sum = Vector((0.0, 0.0, 0.0))
        for v in vlist:
            for f in v.link_faces:
                fn_sum += f.normal * max(f.calc_area(), 1e-5)
        welded_n[k] = fn_sum.normalized() if fn_sum.length > 1e-6 else Vector((0.0, 0.0, 1.0))

    new_cn = [Vector((0.0, 0.0, 1.0))] * len(mesh_obj.data.loops)
    for f in bm.faces:
        for l in f.loops:
            new_cn[l.index] = welded_n[vert_to_key[l.vert.index]]

    bm.to_mesh(mesh_obj.data)
    mesh_obj.data.update()
    mesh_obj.data.normals_split_custom_set(new_cn)
    bm.free()


def sculpt_killian_frontier_hat(hat_obj):
    # Esculpe en Blender el sombrero de Killian Darkwater:
    # - Ensancha el ala frontal/lateral (+16%) con curvatura vaquera ascendente en los flancos
    # - Eleva y estiliza la corona frontal (+1.4 unidades) con hendidura de sheriff en la cima
    bm = bmesh.new()
    bm.from_mesh(hat_obj.data)
    bm.verts.ensure_lookup_table()

    mw = hat_obj.matrix_world
    inv_mw = mw.inverted()
    wcoords = [mw @ v.co for v in bm.verts]
    if not wcoords:
        bm.free()
        return
    z_min = min(c.z for c in wcoords)
    z_max = max(c.z for c in wcoords)
    z_span = max(z_max - z_min, 1.0)
    cx = 0.5 * (min(c.x for c in wcoords) + max(c.x for c in wcoords))
    cy = 0.5 * (min(c.y for c in wcoords) + max(c.y for c in wcoords))

    for v in bm.verts:
        wco = mw @ v.co
        tz = (wco.z - z_min) / z_span
        dx = wco.x - cx
        dy = wco.y - cy
        rad = math.hypot(dx, dy)
        # Ensanchar el ala exterior y curvar los bordes laterales hacia arriba (estilo sombrero fronterizo)
        if rad > 5.2 and tz < 0.58:
            brim_t = min(1.0, (rad - 5.2) / 4.5)
            wco.x = cx + dx * (1.0 + 0.16 * brim_t)
            wco.y = cy + dy * (1.0 + 0.12 * brim_t)
            side_curl = min(1.0, (abs(dx) / 7.5) ** 1.6)
            wco.z += 0.95 * brim_t * side_curl
        # Elevar la corona superior con pellizco frontal de alcalde/sheriff
        if tz > 0.55:
            crown_t = (tz - 0.55) / 0.45
            pinch = math.cos(min(1.0, abs(dx) / 4.8) * 0.5 * math.pi) ** 2
            wco.z += 1.35 * crown_t * (0.45 + 0.55 * pinch)
        v.co = inv_mw @ wco

    bm.to_mesh(hat_obj.data)
    hat_obj.data.update()
    bm.free()
    recompute_welded_normals(hat_obj)


def sculpt_lars_tactical_crest_helmet(helm_obj):
    # Esculpe en Blender el casco táctico de la Guardia de Ciudad Chatarra del Capitán Lars:
    # - Añade una cresta dorsal blindada a lo largo del eje central superior del casco
    # - Proyecta la visera frontal hacia delante e inclina las placas laterales de protección
    bm = bmesh.new()
    bm.from_mesh(helm_obj.data)
    bm.verts.ensure_lookup_table()

    mw = helm_obj.matrix_world
    inv_mw = mw.inverted()
    wcoords = [mw @ v.co for v in bm.verts]
    if not wcoords:
        bm.free()
        return
    z_min = min(c.z for c in wcoords)
    z_max = max(c.z for c in wcoords)
    z_span = max(z_max - z_min, 1.0)
    cx = 0.5 * (min(c.x for c in wcoords) + max(c.x for c in wcoords))

    for v in bm.verts:
        wco = mw @ v.co
        tz = (wco.z - z_min) / z_span
        dx = abs(wco.x - cx)
        # Cresta dorsal táctica en la bóveda superior
        if tz > 0.62 and dx < 2.6:
            crest_x = math.cos((dx / 2.6) * 0.5 * math.pi) ** 2
            crest_z = min(1.0, (tz - 0.62) / 0.30)
            wco.z += 1.55 * crest_x * crest_z
        # Visera frontal reforzada
        if 0.35 < tz < 0.68 and wco.y < -4.0:
            brow_t = min(1.0, (-4.0 - wco.y) / 4.5)
            wco.y -= 0.85 * brow_t
            wco.z -= 0.25 * brow_t
        v.co = inv_mw @ wco

    bm.to_mesh(helm_obj.data)
    helm_obj.data.update()
    bm.free()
    recompute_welded_normals(helm_obj)


def filter_mesh_islands(mesh_obj, keep_predicate):
    bm = bmesh.new()
    bm.from_mesh(mesh_obj.data)
    bm.verts.ensure_lookup_table()

    visited = set()
    to_delete = []
    for v in bm.verts:
        if v.index in visited:
            continue
        q = deque([v])
        visited.add(v.index)
        comp = []
        while q:
            cur = q.popleft()
            comp.append(cur)
            for e in cur.link_edges:
                nb = e.other_vert(cur)
                if nb.index not in visited:
                    visited.add(nb.index)
                    q.append(nb)
        coords = [mesh_obj.matrix_world @ cv.co for cv in comp]
        if not keep_predicate(coords, len(comp)):
            to_delete.extend(comp)

    if to_delete:
        bmesh.ops.delete(bm, geom=to_delete, context="VERTS")
        bm.to_mesh(mesh_obj.data)
        mesh_obj.data.update()
    bm.free()


def is_rear_patch_island(coords, n):
    max_y = max(c.y for c in coords)
    min_abs_x = min(abs(c.x) for c in coords)
    dz = max(c.z for c in coords) - min(c.z for c in coords)
    if max_y < -6.5:
        if n == 20:
            return True
        if n == 10 and (min_abs_x > 2.40 or dz < 0.5):
            return True
        if n in (9, 8, 6) and min_abs_x > 2.40:
            return True
        if n == 4 and min_abs_x > 2.40 and dz < 0.5:
            return True
    return False


def keep_tycho_desert_ranger_helmet(coords, n):
    min_x = min(c.x for c in coords)
    if n == 102 and min_x > 0.4:
        return False
    if n in (115, 101, 90, 72, 68, 57, 46, 35):
        return True
    if is_rear_patch_island(coords, n):
        return True
    return False


def sculpt_tycho_ranger_helmet(helm_obj):
    # Esculpe el casco de Ranger del Desierto de Tycho:
    # - Cierra el domo occipital posterior y proyecta una visera parasol sobre los lentes ópticos
    bm = bmesh.new()
    bm.from_mesh(helm_obj.data)
    bm.verts.ensure_lookup_table()
    mw = helm_obj.matrix_world
    inv_mw = mw.inverted()
    for v in bm.verts:
        wco = mw @ v.co
        # Visera parasol de Ranger sobre la parte superior de la lente frontal
        if 121.0 < wco.z < 125.5 and wco.y > 4.2:
            visor_t = min(1.0, (wco.y - 4.2) / 5.0) * math.cos(min(1.0, abs(wco.x) / 6.8) * 0.5 * math.pi)
            wco.y += 1.25 * visor_t
            wco.z += 0.35 * visor_t
        v.co = inv_mw @ wco
    bm.to_mesh(helm_obj.data)
    helm_obj.data.update()
    bm.free()
    recompute_welded_normals(helm_obj)


def process_and_export(src_nif: str, dst_nif: str, transform_fn, import_collisions: bool = True):
    clear_scene()
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = None
    src_path = os.path.join(TEST_DIR, src_nif)
    dst_path = os.path.join(OUT_DIR, dst_nif)
    bpy.ops.import_scene.pynifly(
        filepath=src_path,
        import_cutpoints=False,
        import_tris=False,
        import_collisions=import_collisions,
    )
    meshes = [o for o in bpy.data.objects if o.type == "MESH" and not o.name.startswith("bhk")]
    transform_fn(meshes)
    meshes = [o for o in bpy.data.objects if o.type == "MESH" and not o.name.startswith("bhk")]

    bpy.ops.object.select_all(action="DESELECT")
    for m in meshes:
        m.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.export_scene.pynifly(filepath=dst_path, target_game="FO4")
    print(f"[Exported V13 Junktown NIF] {dst_nif}")


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    # 1. Sombrero de Alcalde Fronterizo de Killian Darkwater (Masculino, Femenino y GO)
    def xf_killian_hat(meshes):
        for obj in meshes:
            sculpt_killian_frontier_hat(obj)
            for mat in obj.data.materials:
                assign_shader_on_material(
                    mat,
                    r"Materials\V13Chronicles\Junktown\KillianHat.BGSM",
                    r"textures\V13Chronicles\Junktown\KillianHat_d.dds",
                    r"textures\Armor\MacCready\Mac_n.dds",
                    r"textures\Armor\MacCready\Mac_s.dds",
                )

    process_and_export("MacHatM.nif", "KillianMayorHatM.nif", xf_killian_hat)
    process_and_export("MacHatF.nif", "KillianMayorHatF.nif", xf_killian_hat)
    process_and_export("HatGO.nif", "KillianMayorHatGO.nif", xf_killian_hat, import_collisions=True)

    # 2. Casco Táctico con Cresta del Capitán Lars (Masculino, Femenino y GO)
    def xf_lars_helmet(meshes):
        for obj in list(meshes):
            if "HelmetLight" in obj.name or "Light" in obj.name:
                bpy.data.objects.remove(obj, do_unlink=True)
                continue
            sculpt_lars_tactical_crest_helmet(obj)
            for mat in obj.data.materials:
                assign_shader_on_material(
                    mat,
                    r"Materials\V13Chronicles\Junktown\LarsHelm.BGSM",
                    r"textures\V13Chronicles\Junktown\LarsHelm_d.dds",
                    r"textures\Armor\CombatArmor\CombatArmor_Helmet_n.dds",
                    r"textures\Armor\CombatArmor\CombatArmor_Helmet_s.dds",
                )

    process_and_export("M_Helmet.nif", "LarsGuardHelmetM.nif", xf_lars_helmet)
    process_and_export("F_Helmet.nif", "LarsGuardHelmetF.nif", xf_lars_helmet)
    process_and_export("GO_Helmet.nif", "LarsGuardHelmetGO.nif", xf_lars_helmet, import_collisions=True)

    # 3. Casco de Ranger del Desierto de Tycho con Visor Óptico Ámbar-Bronce
    def xf_tycho_helmet(meshes):
        shell_objs = [o for o in meshes if ":1" not in o.name]
        visor_objs = [o for o in meshes if ":1" in o.name]
        for obj in shell_objs:
            filter_mesh_islands(obj, keep_tycho_desert_ranger_helmet)
            sculpt_tycho_ranger_helmet(obj)
            assign_shader_on_material(
                obj.data.materials[0],
                r"Materials\V13Chronicles\Junktown\TychoHelm.BGSM",
                r"textures\V13Chronicles\Junktown\TychoHelm_d.dds",
                r"textures\Armor\FlightHelmet\Helmet_02_n.dds",
                r"textures\Armor\FlightHelmet\Helmet_02_s.dds",
            )
        for obj in visor_objs:
            recompute_welded_normals(obj)
            visor_mat = shell_objs[0].data.materials[0].copy()
            visor_mat.name = "TychoVisor_OpaqueMTS"
            obj.data.materials.clear()
            obj.data.materials.append(visor_mat)
            obj.active_material = visor_mat
            assign_shader_on_material(
                visor_mat,
                r"Materials\V13Chronicles\Junktown\TychoVisor.BGSM",
                r"textures\V13Chronicles\Junktown\TychoVisor_d.dds",
                r"textures\Armor\FlightHelmet\Helmet_02_n.dds",
                r"textures\Armor\FlightHelmet\Helmet_02_s.dds",
                env_dds=r"textures\Shared\Cubemaps\shinyglass_e.dds",
            )

    process_and_export("FlightHelmet02.nif", "TychoRangerHelmet.nif", xf_tycho_helmet)
    process_and_export("helmet02go.nif", "TychoRangerHelmetGO.nif", xf_tycho_helmet, import_collisions=True)

    # 4. Cabina Telefónica Inusual de Fallout 1 (1997) — 1960s British Police Call Box (TARDIS)
    def build_tardis_geometry_on_object(mesh_obj):
        bm = bmesh.new()
        bm.from_mesh(mesh_obj.data)
        uv_layer = bm.loops.layers.uv.active
        if uv_layer is None:
            uv_layer = bm.loops.layers.uv.new("UVMap")
        bmesh.ops.delete(bm, geom=list(bm.verts), context="VERTS")

        def uv_rect(px0, py0, px1, py1):
            return (
                px0 / 1024.0,
                1.0 - (py1 / 1024.0),
                px1 / 1024.0,
                1.0 - (py0 / 1024.0),
            )

        UV_TIMBER = uv_rect(24, 24, 488, 488)
        UV_PILLAR = uv_rect(16, 16, 144, 496)
        UV_WINDOW = uv_rect(516, 4, 1020, 316)
        UV_SIGN = uv_rect(516, 324, 1020, 444)
        UV_PLAQUE = uv_rect(524, 460, 755, 755)
        UV_BADGE = uv_rect(772, 452, 1020, 764)
        UV_PANEL = uv_rect(12, 524, 244, 756)
        UV_LAMP = uv_rect(520, 776, 760, 1016)
        UV_PLINTH = uv_rect(776, 776, 1016, 1016)

        def add_quad(p0, p1, p2, p3, uv_box):
            u0, v0_uv, u1, v1_uv = uv_box
            verts = [bm.verts.new(p0), bm.verts.new(p1), bm.verts.new(p2), bm.verts.new(p3)]
            f = bm.faces.new(verts)
            f.material_index = 0
            f.loops[0][uv_layer].uv = (u0, v0_uv)
            f.loops[1][uv_layer].uv = (u1, v0_uv)
            f.loops[2][uv_layer].uv = (u1, v1_uv)
            f.loops[3][uv_layer].uv = (u0, v1_uv)

        def add_box(x0, x1, y0, y1, z0, z1, uv_front, uv_back=None, uv_left=None, uv_right=None, uv_top=None, uv_bot=None):
            uv_back = uv_back or uv_front
            uv_left = uv_left or uv_front
            uv_right = uv_right or uv_front
            uv_top = uv_top or uv_front
            uv_bot = uv_bot or uv_front
            # Front (-Y)
            add_quad((x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1), uv_front)
            # Back (+Y)
            add_quad((x1, y1, z0), (x0, y1, z0), (x0, y1, z1), (x1, y1, z1), uv_back)
            # Left (-X)
            add_quad((x0, y1, z0), (x0, y0, z0), (x0, y0, z1), (x0, y1, z1), uv_left)
            # Right (+X)
            add_quad((x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (x1, y0, z1), uv_right)
            # Top (+Z)
            add_quad((x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1), uv_top)
            # Bottom (-Z)
            add_quad((x0, y1, z0), (x1, y1, z0), (x1, y0, z0), (x0, y0, z0), uv_bot)

        # 1. Stepped Base Plinth (Z: 0..10)
        add_box(-62.0, 62.0, -62.0, 62.0, 0.0, 6.0, UV_PLINTH)
        add_box(-58.0, 58.0, -58.0, 58.0, 6.0, 10.0, UV_TIMBER)

        # 2. 4 Fluted Corner Pillars (Z: 10..216)
        for sx in (-1.0, 1.0):
            for sy in (-1.0, 1.0):
                cx, cy = sx * 50.0, sy * 50.0
                add_box(cx - 7.5, cx + 7.5, cy - 7.5, cy + 7.5, 10.0, 216.0, UV_PILLAR, uv_top=UV_TIMBER)
                # Outer trim flute strip on each pillar
                add_box(cx - 5.5, cx + 5.5, cy - 8.5, cy + 8.5, 12.0, 214.0, UV_PILLAR, uv_top=UV_TIMBER)
                add_box(cx - 8.5, cx + 8.5, cy - 5.5, cy + 5.5, 12.0, 214.0, UV_PILLAR, uv_top=UV_TIMBER)

        # 3. Inner Recessed Core Box (Z: 10..202) — provides the recessed panel & window backdrops
        # We build each of the 4 sides explicitly so each panel & window has exact UVs!
        w_in = 43.0
        # Core interior backing block behind stiles/rails
        add_box(-w_in, w_in, -w_in, w_in, 10.0, 202.0, UV_TIMBER)

        # Helper to build the framed stiles, rails, 3x2 recessed panels, and 2x1 upper windows on all 4 sides
        z_rails = [
            (10.0, 16.0),
            (52.0, 58.0),
            (94.0, 100.0),
            (136.0, 144.0),
            (194.0, 202.0),
        ]
        z_panel_rows = [
            (16.0, 52.0),   # Row 0 (bottom)
            (58.0, 94.0),   # Row 1 (middle: plaque & badge on front!)
            (100.0, 136.0), # Row 2 (upper-middle)
        ]
        z_win = (144.0, 194.0)

        # Front (-Y) and Back (+Y) stiles & rails
        for side_y, is_front in ((-1.0, True), (1.0, False)):
            y_base = side_y * 43.0
            y_out = side_y * 46.5
            y0, y1 = (y_out, y_base) if is_front else (y_base, y_out)
            # Left stile (-43..-37), Center mullion (-3..+3), Right stile (+37..+43)
            for sx0, sx1 in ((-43.0, -37.0), (-3.5, 3.5), (37.0, 43.0)):
                add_box(sx0, sx1, y0, y1, 10.0, 202.0, UV_TIMBER)
            # Horizontal rails
            for rz0, rz1 in z_rails:
                add_box(-37.0, -3.5, y0, y1, rz0, rz1, UV_TIMBER)
                add_box(3.5, 37.0, y0, y1, rz0, rz1, UV_TIMBER)
            # Recessed panels (y slightly proud of y_base)
            yp_out = side_y * 43.8
            py0, py1 = (yp_out, y_base) if is_front else (y_base, yp_out)
            for r_idx, (pz0, pz1) in enumerate(z_panel_rows):
                # Left column (-37..-3.5) and Right column (+3.5..+37)
                if is_front and r_idx == 2:
                    # Front upper-middle left: Raised white instruction plaque ("PULL TO OPEN")
                    add_box(-35.5, -5.0, -45.2, y_base, pz0 + 1.5, pz1 - 1.5, UV_PLAQUE, uv_back=UV_TIMBER, uv_left=UV_TIMBER, uv_right=UV_TIMBER, uv_top=UV_TIMBER, uv_bot=UV_TIMBER)
                    # Small brass/silver door pull handle next to plaque
                    add_box(-2.8, -1.2, -47.8, -45.0, pz0 + 12.0, pz0 + 22.0, UV_PLINTH)
                    # Front upper-middle right: St. John Ambulance Circular Crest + Yale Lock
                    add_box(3.5, 37.0, py0, py1, pz0, pz1, UV_BADGE)
                else:
                    add_box(-37.0, -3.5, py0, py1, pz0, pz1, UV_PANEL)
                    add_box(3.5, 37.0, py0, py1, pz0, pz1, UV_PANEL)
            # Upper windows (Z: 144..194)
            add_box(-37.0, -3.5, py0, py1, z_win[0], z_win[1], UV_WINDOW)
            add_box(3.5, 37.0, py0, py1, z_win[0], z_win[1], UV_WINDOW)

        # Left (-X) and Right (+X) stiles & rails
        for side_x, is_left in ((-1.0, True), (1.0, False)):
            x_base = side_x * 43.0
            x_out = side_x * 46.5
            x0, x1 = (x_out, x_base) if is_left else (x_base, x_out)
            for sy0, sy1 in ((-43.0, -37.0), (-3.5, 3.5), (37.0, 43.0)):
                add_box(x0, x1, sy0, sy1, 10.0, 202.0, UV_TIMBER)
            for rz0, rz1 in z_rails:
                add_box(x0, x1, -37.0, -3.5, rz0, rz1, UV_TIMBER)
                add_box(x0, x1, 3.5, 37.0, rz0, rz1, UV_TIMBER)
            xp_out = side_x * 43.8
            px0, px1 = (xp_out, x_base) if is_left else (x_base, xp_out)
            for pz0, pz1 in z_panel_rows:
                add_box(px0, px1, -37.0, -3.5, pz0, pz1, UV_PANEL)
                add_box(px0, px1, 3.5, 37.0, pz0, pz1, UV_PANEL)
            add_box(px0, px1, -37.0, -3.5, z_win[0], z_win[1], UV_WINDOW)
            add_box(px0, px1, 3.5, 37.0, z_win[0], z_win[1], UV_WINDOW)

        # 4. Overhanging Top Sign Boxes ("POLICE • PUBLIC CALL BOX", Z: 200..216)
        # Main sign fascia block
        add_box(-54.0, 54.0, -54.0, 54.0, 200.0, 216.0, UV_TIMBER)
        # Front & Back projecting sign lintels
        add_box(-48.0, 48.0, -58.5, -53.5, 201.5, 214.5, UV_SIGN, uv_back=UV_TIMBER, uv_left=UV_TIMBER, uv_right=UV_TIMBER, uv_top=UV_TIMBER, uv_bot=UV_TIMBER)
        add_box(-48.0, 48.0, 53.5, 58.5, 201.5, 214.5, UV_TIMBER, uv_back=UV_SIGN, uv_left=UV_TIMBER, uv_right=UV_TIMBER, uv_top=UV_TIMBER, uv_bot=UV_TIMBER)
        # Left & Right projecting sign lintels
        add_box(-58.5, -53.5, -48.0, 48.0, 201.5, 214.5, UV_TIMBER, uv_back=UV_TIMBER, uv_left=UV_SIGN, uv_right=UV_TIMBER, uv_top=UV_TIMBER, uv_bot=UV_TIMBER)
        add_box(53.5, 58.5, -48.0, 48.0, 201.5, 214.5, UV_TIMBER, uv_back=UV_TIMBER, uv_left=UV_TIMBER, uv_right=UV_SIGN, uv_top=UV_TIMBER, uv_bot=UV_TIMBER)

        # 5. Stepped Pyramidal Roof (Z: 216..242)
        add_box(-52.0, 52.0, -52.0, 52.0, 216.0, 223.0, UV_TIMBER)
        add_box(-45.0, 45.0, -45.0, 45.0, 223.0, 229.0, UV_TIMBER)
        # Sloped pyramidal roof cap from +-44 (Z=229) to +-11 (Z=241)
        rb0, rb1, rt0, rt1, rz0, rz1 = -44.0, 44.0, -11.0, 11.0, 229.0, 241.0
        add_quad((rb0, rb0, rz0), (rb1, rb0, rz0), (rt1, rt0, rz1), (rt0, rt0, rz1), UV_TIMBER)
        add_quad((rb1, rb1, rz0), (rb0, rb1, rz0), (rt0, rt1, rz1), (rt1, rt1, rz1), UV_TIMBER)
        add_quad((rb0, rb1, rz0), (rb0, rb0, rz0), (rt0, rt0, rz1), (rt0, rt1, rz1), UV_TIMBER)
        add_quad((rb1, rb0, rz0), (rb1, rb1, rz0), (rt1, rt1, rz1), (rt1, rt0, rz1), UV_TIMBER)
        add_quad((rt0, rt0, rz1), (rt1, rt0, rz1), (rt1, rt1, rz1), (rt0, rt1, rz1), UV_TIMBER)

        # 6. Top Fresnel Beacon Lamp (Z: 241..268)
        # Base collar
        add_box(-9.5, 9.5, -9.5, 9.5, 241.0, 246.0, UV_PLINTH)
        # Octagonal/12-sided cylindrical Fresnel glass lantern (Z: 246..261, radius 7.2)
        n_sides = 12
        r_lamp = 7.2
        r_cap = 9.0
        for i in range(n_sides):
            a0 = (2.0 * math.pi * i) / n_sides
            a1 = (2.0 * math.pi * (i + 1)) / n_sides
            x0_l, y0_l = r_lamp * math.cos(a0), r_lamp * math.sin(a0)
            x1_l, y1_l = r_lamp * math.cos(a1), r_lamp * math.sin(a1)
            add_quad((x0_l, y0_l, 246.0), (x1_l, y1_l, 246.0), (x1_l, y1_l, 261.0), (x0_l, y0_l, 261.0), UV_LAMP)
            # Conical lamp cap (Z: 261..267)
            x0_c, y0_c = r_cap * math.cos(a0), r_cap * math.sin(a0)
            x1_c, y1_c = r_cap * math.cos(a1), r_cap * math.sin(a1)
            x0_t, y0_t = 1.8 * math.cos(a0), 1.8 * math.sin(a0)
            x1_t, y1_t = 1.8 * math.cos(a1), 1.8 * math.sin(a1)
            add_quad((x0_c, y0_c, 261.0), (x1_c, y1_c, 261.0), (x1_t, y1_t, 267.0), (x0_t, y0_t, 267.0), UV_PLINTH)
        add_box(-8.5, 8.5, -8.5, 8.5, 260.2, 261.5, UV_PLINTH)
        # 4 Protective vertical cage struts around the beacon lamp
        for ang_deg in (45.0, 135.0, 225.0, 315.0):
            rad = math.radians(ang_deg)
            sx, sy = 8.0 * math.cos(rad), 8.0 * math.sin(rad)
            add_box(sx - 0.7, sx + 0.7, sy - 0.7, sy + 0.7, 245.0, 262.0, UV_PLINTH)

        bmesh.ops.triangulate(bm, faces=list(bm.faces))
        bm.to_mesh(mesh_obj.data)
        bm.free()
        mesh_obj.data.update()
        recompute_welded_normals(mesh_obj)

    def xf_tardis_box(meshes):
        main_obj = meshes[0]
        for extra in list(meshes[1:]):
            bpy.data.objects.remove(extra, do_unlink=True)
        if main_obj.parent and main_obj.parent.type == "ARMATURE":
            arm_obj = main_obj.parent
            main_obj.parent = arm_obj.parent
            bpy.data.objects.remove(arm_obj, do_unlink=True)
        for obj in list(bpy.data.objects):
            if obj.type == "ARMATURE":
                bpy.data.objects.remove(obj, do_unlink=True)
        main_obj.modifiers.clear()
        main_obj.vertex_groups.clear()
        build_tardis_geometry_on_object(main_obj)
        for mat in main_obj.data.materials:
            assign_shader_on_material(
                mat,
                r"Materials\V13Chronicles\Junktown\TardisPoliceBox.BGSM",
                r"textures\V13Chronicles\Junktown\TardisPoliceBox_d.dds",
                r"textures\Shared\FlatFlat_n.dds",
                r"textures\interiors\vault\VltNULLforSWAP_s.dds",
            )

    process_and_export("CabinetGarage02.nif", "TardisPoliceBox.nif", xf_tardis_box, import_collisions=True)

    # 5. Cuadro de Terciopelo de «El Rey» (Elvis Presley — Fallout 1 'Fuzzy Painting' en el Platillo Volante)
    def build_elvis_painting_geometry_on_object(mesh_obj):
        bm = bmesh.new()
        bm.from_mesh(mesh_obj.data)
        uv_layer = bm.loops.layers.uv.active
        if uv_layer is None:
            uv_layer = bm.loops.layers.uv.new("UVMap")
        bmesh.ops.delete(bm, geom=list(bm.verts), context="VERTS")

        def uv_rect(px0, py0, px1, py1):
            return (
                px0 / 1024.0,
                1.0 - (py1 / 1024.0),
                px1 / 1024.0,
                1.0 - (py0 / 1024.0),
            )

        UV_FRONT = uv_rect(8, 8, 504, 632)
        UV_BACK = uv_rect(520, 8, 1016, 632)
        UV_FRAME_H = uv_rect(24, 656, 1000, 1000)
        UV_FRAME_V = uv_rect(24, 656, 480, 1000)

        def add_quad(p0, p1, p2, p3, uv_box):
            u0, v0_uv, u1, v1_uv = uv_box
            verts = [bm.verts.new(p0), bm.verts.new(p1), bm.verts.new(p2), bm.verts.new(p3)]
            f = bm.faces.new(verts)
            f.material_index = 0
            f.loops[0][uv_layer].uv = (u0, v0_uv)
            f.loops[1][uv_layer].uv = (u1, v0_uv)
            f.loops[2][uv_layer].uv = (u1, v1_uv)
            f.loops[3][uv_layer].uv = (u0, v1_uv)

        def add_box(x0, x1, y0, y1, z0, z1, uv_front, uv_back=None, uv_left=None, uv_right=None, uv_top=None, uv_bot=None):
            uv_back = uv_back or uv_front
            uv_left = uv_left or uv_front
            uv_right = uv_right or uv_front
            uv_top = uv_top or uv_front
            uv_bot = uv_bot or uv_front
            add_quad((x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1), uv_front)
            add_quad((x1, y1, z0), (x0, y1, z0), (x0, y1, z1), (x1, y1, z1), uv_back)
            add_quad((x0, y1, z0), (x0, y0, z0), (x0, y0, z1), (x0, y1, z1), uv_left)
            add_quad((x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (x1, y0, z1), uv_right)
            add_quad((x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1), uv_top)
            add_quad((x0, y1, z0), (x1, y1, z0), (x1, y0, z0), (x0, y0, z0), uv_bot)

        # Recessed Velvet Portrait Canvas & Backboard (X: -12.5..12.5, Y: -1.1..1.1, Z: 3.0..33.0)
        add_box(-12.5, 12.5, -1.1, 1.1, 3.0, 33.0, UV_FRONT, uv_back=UV_BACK, uv_left=UV_FRAME_V, uv_right=UV_FRAME_V, uv_top=UV_FRAME_H, uv_bot=UV_FRAME_H)
        # Carved Gilded Wooden Frame (Bottom, Top, Left, Right rails + Inner lip)
        add_box(-15.5, 15.5, -2.2, 2.0, 0.0, 3.5, UV_FRAME_H)
        add_box(-15.5, 15.5, -2.2, 2.0, 32.5, 36.0, UV_FRAME_H)
        add_box(-15.5, -12.0, -2.2, 2.0, 3.5, 32.5, UV_FRAME_V)
        add_box(12.0, 15.5, -2.2, 2.0, 3.5, 32.5, UV_FRAME_V)
        # Inner gold bevel molding
        add_box(-12.8, 12.8, -1.6, -1.0, 2.8, 3.8, UV_FRAME_H)
        add_box(-12.8, 12.8, -1.6, -1.0, 32.2, 33.2, UV_FRAME_H)
        add_box(-12.8, -11.6, -1.6, -1.0, 3.8, 32.2, UV_FRAME_V)
        add_box(11.6, 12.8, -1.6, -1.0, 3.8, 32.2, UV_FRAME_V)

        bmesh.ops.triangulate(bm, faces=list(bm.faces))
        bm.to_mesh(mesh_obj.data)
        bm.free()
        mesh_obj.data.update()
        recompute_welded_normals(mesh_obj)

    def xf_elvis_painting(meshes):
        main_obj = meshes[0]
        for extra in list(meshes[1:]):
            bpy.data.objects.remove(extra, do_unlink=True)
        if main_obj.parent and main_obj.parent.type == "ARMATURE":
            arm_obj = main_obj.parent
            main_obj.parent = arm_obj.parent
            bpy.data.objects.remove(arm_obj, do_unlink=True)
        for obj in list(bpy.data.objects):
            if obj.type == "ARMATURE":
                bpy.data.objects.remove(obj, do_unlink=True)
        main_obj.modifiers.clear()
        main_obj.vertex_groups.clear()
        build_elvis_painting_geometry_on_object(main_obj)
        for mat in main_obj.data.materials:
            assign_shader_on_material(
                mat,
                r"Materials\V13Chronicles\Junktown\ElvisVelvetPainting.BGSM",
                r"textures\V13Chronicles\Junktown\ElvisVelvetPainting_d.dds",
                r"textures\Shared\FlatFlat_n.dds",
                r"textures\interiors\vault\VltNULLforSWAP_s.dds",
            )

    process_and_export("HatGO.nif", "ElvisVelvetPainting.nif", xf_elvis_painting, import_collisions=True)

    # 6. Huella Gigante de Godzilla (Fallout 1 'Giant Footprint' — Cráter de Tres Dedos con Garras en el Desierto)
    def build_giant_footprint_geometry_on_object(mesh_obj):
        bm = bmesh.new()
        bm.from_mesh(mesh_obj.data)
        uv_layer = bm.loops.layers.uv.active
        if uv_layer is None:
            uv_layer = bm.loops.layers.uv.new("UVMap")
        bmesh.ops.delete(bm, geom=list(bm.verts), context="VERTS")

        def seg_sdf(px, py, ax, ay, bx, by, ra, rb):
            vx, vy = bx - ax, by - ay
            wx, wy = px - ax, py - ay
            t = max(0.0, min(1.0, (wx * vx + wy * vy) / (vx * vx + vy * vy + 1e-8)))
            dist = math.hypot(wx - t * vx, wy - t * vy)
            rad = ra + t * (rb - ra)
            return dist - rad

        def smin_f(a, b, k):
            h = max(0.0, min(1.0, 0.5 + 0.5 * (b - a) / k))
            return b * (1.0 - h) + a * h - k * h * (1.0 - h)

        def sstep_f(e0, e1, x):
            t = max(0.0, min(1.0, (x - e0) / (e1 - e0)))
            return t * t * (3.0 - 2.0 * t)

        N_GRID = 76
        v_grid = [[None] * N_GRID for _ in range(N_GRID)]
        uv_grid = [[(0.0, 0.0)] * N_GRID for _ in range(N_GRID)]
        dfp_grid = [[0.0] * N_GRID for _ in range(N_GRID)]

        for ir in range(N_GRID):
            ty = ir / (N_GRID - 1.0)
            dy = -436.0 + ty * 1080.0
            for ic in range(N_GRID):
                tx = ic / (N_GRID - 1.0)
                dx = -540.0 + tx * 1080.0

                d_sole = seg_sdf(dx, dy, 0.0, -160.0, 0.0, 10.0, 115.0, 180.0)
                d_toe_l = seg_sdf(dx, dy, -95.0, 15.0, -290.0, 295.0, 105.0, 58.0)
                d_toe_m = seg_sdf(dx, dy, 0.0, 25.0, 0.0, 375.0, 116.0, 62.0)
                d_toe_r = seg_sdf(dx, dy, 95.0, 15.0, 290.0, 295.0, 105.0, 58.0)
                d_toes = min(d_toe_l, d_toe_m, d_toe_r)
                d_body = smin_f(d_sole, d_toes, 16.0)

                d_claw_l = seg_sdf(dx, dy, -290.0, 295.0, -362.0, 385.0, 38.0, 12.0)
                d_claw_m = seg_sdf(dx, dy, 0.0, 375.0, 0.0, 472.0, 42.0, 12.0)
                d_claw_r = seg_sdf(dx, dy, 290.0, 295.0, 362.0, 385.0, 38.0, 12.0)
                d_claws = min(d_claw_l, d_claw_m, d_claw_r)
                d_fp = min(d_body, d_claws)
                dfp_grid[ir][ic] = d_fp

                # Local Z relative to flat ground Z_world = 160.0 (so z_loc = 0.0 is Z = 160.0):
                # - Inside sole & toes (d_fp < -18): compressed floor at z_loc = 1.6 (claw gouges at 0.7), right above Z=160 LAND
                # - Inner crater wall (-18 <= d_fp < 12): steep 22.4-unit sheared mud wall rising from 1.6 up to 24.0
                # - Outer displaced mud rim (12 <= d_fp <= 88): slopes down from 24.0 through 0.0 (at d_fp=64) to -6.0 (buried underground)
                rim_rock = 1.8 * math.sin(dx * 0.045 + dy * 0.038) + 1.1 * math.cos(dx * 0.082 - dy * 0.071)
                if d_fp < -18.0:
                    z_loc = 1.6 + 0.45 * math.sin(dx * 0.065) * math.cos(dy * 0.065)
                    if d_claws < -4.0:
                        claw_w = sstep_f(-4.0, -18.0, d_claws)
                        z_loc = z_loc * (1.0 - claw_w) + 0.7 * claw_w
                elif d_fp < 12.0:
                    w_wall = sstep_f(-18.0, 12.0, d_fp)
                    z_loc = 1.6 * (1.0 - w_wall) + (24.0 + rim_rock) * w_wall
                else:
                    w_out = sstep_f(12.0, 86.0, d_fp)
                    z_loc = (24.0 + rim_rock * (1.0 - w_out)) * (1.0 - w_out) + (-6.0) * w_out

                v_grid[ir][ic] = bm.verts.new((dx, dy, z_loc))
                uv_grid[ir][ic] = (0.02 + 0.96 * tx, 0.02 + 0.96 * ty)

        # Contour-trim the mesh to the three-toed Godzilla footprint rim (d_fp <= 78.0):
        # zero outer square apron, and every boundary edge is at z_loc ~ -5.0..-6.0 (buried beneath Z=160.0 LAND)
        for ir in range(N_GRID - 1):
            for ic in range(N_GRID - 1):
                if min(
                    dfp_grid[ir][ic],
                    dfp_grid[ir][ic + 1],
                    dfp_grid[ir + 1][ic + 1],
                    dfp_grid[ir + 1][ic],
                ) > 78.0:
                    continue
                v00 = v_grid[ir][ic]
                v10 = v_grid[ir][ic + 1]
                v11 = v_grid[ir + 1][ic + 1]
                v01 = v_grid[ir + 1][ic]
                f = bm.faces.new((v00, v10, v11, v01))
                f.material_index = 0
                f.loops[0][uv_layer].uv = uv_grid[ir][ic]
                f.loops[1][uv_layer].uv = uv_grid[ir][ic + 1]
                f.loops[2][uv_layer].uv = uv_grid[ir + 1][ic + 1]
                f.loops[3][uv_layer].uv = uv_grid[ir + 1][ic]

        loose_verts = [v for v in bm.verts if not v.link_faces]
        if loose_verts:
            bmesh.ops.delete(bm, geom=loose_verts, context="VERTS")

        bmesh.ops.triangulate(bm, faces=list(bm.faces))
        bm.to_mesh(mesh_obj.data)
        bm.free()
        mesh_obj.data.update()
        recompute_welded_normals(mesh_obj)

    def xf_giant_footprint(meshes):
        main_obj = meshes[0]
        for extra in list(meshes[1:]):
            bpy.data.objects.remove(extra, do_unlink=True)
        if main_obj.parent and main_obj.parent.type == "ARMATURE":
            arm_obj = main_obj.parent
            main_obj.parent = arm_obj.parent
            bpy.data.objects.remove(arm_obj, do_unlink=True)
        for obj in list(bpy.data.objects):
            if obj.type == "ARMATURE":
                bpy.data.objects.remove(obj, do_unlink=True)
        main_obj.modifiers.clear()
        main_obj.vertex_groups.clear()
        build_giant_footprint_geometry_on_object(main_obj)
        for mat in main_obj.data.materials:
            assign_shader_on_material(
                mat,
                r"Materials\V13Chronicles\Junktown\GiantFootprint.BGSM",
                r"textures\V13Chronicles\Junktown\GiantFootprint_d.dds",
                r"textures\Shared\FlatFlat_n.dds",
                r"textures\interiors\vault\VltNULLforSWAP_s.dds",
            )

    process_and_export("CabinetGarage02.nif", "GiantGodzillaFootprint.nif", xf_giant_footprint, import_collisions=False)


if __name__ == "__main__":
    main()
