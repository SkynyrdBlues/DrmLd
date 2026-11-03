import bpy
from pathlib import Path

root = Path(__file__).resolve().parents[1]
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.5))
obj = bpy.context.object
obj.name = "PipelineSample"
material = bpy.data.materials.new("SampleMaterial")
material.diffuse_color = (0.65, 0.42, 0.32, 1)
obj.data.materials.append(material)
bpy.ops.wm.save_as_mainfile(filepath=str(root / "source_assets/pipeline_sample.blend"))
bpy.ops.export_scene.gltf(filepath=str(root / "game/assets/models/pipeline_sample.glb"), export_format="GLB", use_selection=True)
