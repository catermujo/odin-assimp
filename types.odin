package assimp

import "core:c"

_ :: c

Post_Process :: enum c.int {
    /** <hr>Calculates the tangents and bitangents for the imported meshes.
	*
	* Does nothing if a mesh does not have normals. You might want this post
	* processing step to be executed if you plan to use tangent space calculations
	* such as normal mapping  applied to the meshes. There's an importer property,
	* <tt>#AI_CONFIG_PP_CT_MAX_SMOOTHING_ANGLE</tt>, which allows you to specify
	* a maximum smoothing angle for the algorithm. However, usually you'll
	* want to leave it at the default value.
	*/
    CalcTangentSpace,
    /** <hr>Identifies and joins identical vertex data sets within all
	*  imported meshes.
	*
	* After this step is run, each mesh contains unique vertices,
	* so a vertex may be used by multiple faces. You usually want
	* to use this post processing step. If your application deals with
	* indexed geometry, this step is compulsory or you'll just waste rendering
	* time. <b>If this flag is not specified</b>, no vertices are referenced by
	* more than one face and <b>no index buffer is required</b> for rendering.
	* Unless the importer (like ply) had to split vertices. Then you need one regardless.
	*/
    JoinIdenticalVertices,
    /** <hr>Converts all the imported data to a left-handed coordinate space.
	*
	* By default the data is returned in a right-handed coordinate space (which
	* OpenGL prefers). In this space, +X points to the right,
	* +Z points towards the viewer, and +Y points upwards. In the DirectX
	* coordinate space +X points to the right, +Y points upwards, and +Z points
	* away from the viewer.
	*
	* You'll probably want to consider this flag if you use Direct3D for
	* rendering. The #aiProcess_ConvertToLeftHanded flag supersedes this
	* setting and bundles all conversions typically required for D3D-based
	* applications.
	*/
    MakeLeftHanded,
    /** <hr>Triangulates all faces of all meshes.
	*
	* By default the imported mesh data might contain faces with more than 3
	* indices. For rendering you'll usually want all faces to be triangles.
	* This post processing step splits up faces with more than 3 indices into
	* triangles. Line and point primitives are *not* modified! If you want
	* 'triangles only' with no other kinds of primitives, try the following
	* solution:
	* <ul>
	* <li>Specify both #aiProcess_Triangulate and #aiProcess_SortByPType </li>
	* <li>Ignore all point and line meshes when you process assimp's output</li>
	* </ul>
	*/
    Triangulate,
    /** <hr>Removes some parts of the data structure (animations, materials,
	*  light sources, cameras, textures, vertex components).
	*
	* The  components to be removed are specified in a separate
	* importer property, <tt>#AI_CONFIG_PP_RVC_FLAGS</tt>. This is quite useful
	* if you don't need all parts of the output structure. Vertex colors
	* are rarely used today for example... Calling this step to remove unneeded
	* data from the pipeline as early as possible results in increased
	* performance and a more optimized output data structure.
	* This step is also useful if you want to force Assimp to recompute
	* normals or tangents. The corresponding steps don't recompute them if
	* they're already there (loaded from the source asset). By using this
	* step you can make sure they are NOT there.
	*
	* This flag is a poor one, mainly because its purpose is usually
	* misunderstood. Consider the following case: a 3D model has been exported
	* from a CAD app, and it has per-face vertex colors. Vertex positions can't be
	* shared, thus the #aiProcess_JoinIdenticalVertices step fails to
	* optimize the data because of these nasty little vertex colors.
	* Most apps don't even process them, so it's all for nothing. By using
	* this step, unneeded components are excluded as early as possible
	* thus opening more room for internal optimizations.
	*/
    RemoveComponent,
    /** <hr>Generates normals for all faces of all meshes.
	*
	* This is ignored if normals are already there at the time this flag
	* is evaluated. Model importers try to load them from the source file, so
	* they're usually already there. Face normals are shared between all points
	* of a single face, so a single point can have multiple normals, which
	* forces the library to duplicate vertices in some cases.
	* #aiProcess_JoinIdenticalVertices is *senseless* then.
	*
	* This flag may not be specified together with #aiProcess_GenSmoothNormals.
	*/
    GenNormals,
    /** <hr>Generates smooth normals for all vertices in the mesh.
	*
	* This is ignored if normals are already there at the time this flag
	* is evaluated. Model importers try to load them from the source file, so
	* they're usually already there.
	*
	* This flag may not be specified together with
	* #aiProcess_GenNormals. There's a importer property,
	* <tt>#AI_CONFIG_PP_GSN_MAX_SMOOTHING_ANGLE</tt> which allows you to specify
	* an angle maximum for the normal smoothing algorithm. Normals exceeding
	* this limit are not smoothed, resulting in a 'hard' seam between two faces.
	* Using a decent angle here (e.g. 80 degrees) results in very good visual
	* appearance.
	*/
    GenSmoothNormals,
    /** <hr>Splits large meshes into smaller sub-meshes.
	*
	* This is quite useful for real-time rendering, where the number of triangles
	* which can be maximally processed in a single draw-call is limited
	* by the video driver/hardware. The maximum vertex buffer is usually limited
	* too. Both requirements can be met with this step: you may specify both a
	* triangle and vertex limit for a single mesh.
	*
	* The split limits can (and should!) be set through the
	* <tt>#AI_CONFIG_PP_SLM_VERTEX_LIMIT</tt> and <tt>#AI_CONFIG_PP_SLM_TRIANGLE_LIMIT</tt>
	* importer properties. The default values are <tt>#AI_SLM_DEFAULT_MAX_VERTICES</tt> and
	* <tt>#AI_SLM_DEFAULT_MAX_TRIANGLES</tt>.
	*
	* Note that splitting is generally a time-consuming task, but only if there's
	* something to split. The use of this step is recommended for most users.
	*/
    SplitLargeMeshes,
    /** <hr>Removes the node graph and pre-transforms all vertices with
	* the local transformation matrices of their nodes.
	*
	* If the resulting scene can be reduced to a single mesh, with a single
	* material, no lights, and no cameras, then the output scene will contain
	* only a root node (with no children) that references the single mesh.
	* Otherwise, the output scene will be reduced to a root node with a single
	* level of child nodes, each one referencing one mesh, and each mesh
	* referencing one material.
	*
	* In either case, for rendering, you can
	* simply render all meshes in order - you don't need to pay
	* attention to local transformations and the node hierarchy.
	* Animations are removed during this step.
	* This step is intended for applications without a scenegraph.
	* The step CAN cause some problems: if e.g. a mesh of the asset
	* contains normals and another, using the same material index, does not,
	* they will be brought together, but the first meshes's part of
	* the normal list is zeroed. However, these artifacts are rare.
	* @note The <tt>#AI_CONFIG_PP_PTV_NORMALIZE</tt> configuration property
	* can be set to normalize the scene's spatial dimension to the -1...1
	* range.
	*/
    PreTransformVertices,
    /** <hr>Limits the number of bones simultaneously affecting a single vertex
	*  to a maximum value.
	*
	* If any vertex is affected by more than the maximum number of bones, the least
	* important vertex weights are removed and the remaining vertex weights are
	* renormalized so that the weights still sum up to 1.
	* The default bone weight limit is 4 (defined as <tt>#AI_LMW_MAX_WEIGHTS</tt> in
	* config.h), but you can use the <tt>#AI_CONFIG_PP_LBW_MAX_WEIGHTS</tt> importer
	* property to supply your own limit to the post processing step.
	*
	* If you intend to perform the skinning in hardware, this post processing
	* step might be of interest to you.
	*/
    LimitBoneWeights,
    /** <hr>Validates the imported scene data structure.
	* This makes sure that all indices are valid, all animations and
	* bones are linked correctly, all material references are correct .. etc.
	*
	* It is recommended that you capture Assimp's log output if you use this flag,
	* so you can easily find out what's wrong if a file fails the
	* validation. The validator is quite strict and will find *all*
	* inconsistencies in the data structure... It is recommended that plugin
	* developers use it to debug their loaders. There are two types of
	* validation failures:
	* <ul>
	* <li>Error: There's something wrong with the imported data. Further
	*   postprocessing is not possible and the data is not usable at all.
	*   The import fails. #Importer::GetErrorString() or #aiGetErrorString()
	*   carry the error message around.</li>
	* <li>Warning: There are some minor issues (e.g. 1000000 animation
	*   keyframes with the same time), but further postprocessing and use
	*   of the data structure is still safe. Warning details are written
	*   to the log file, <tt>#AI_SCENE_FLAGS_VALIDATION_WARNING</tt> is set
	*   in #aiScene::mFlags</li>
	* </ul>
	*
	* This post-processing step is not time-consuming. Its use is not
	* compulsory, but recommended.
	*/
    ValidateDataStructure,
    /** <hr>Reorders triangles for better vertex cache locality.
	*
	* The step tries to improve the ACMR (average post-transform vertex cache
	* miss ratio) for all meshes. The implementation runs in O(n) and is
	* roughly based on the 'tipsify' algorithm (see <a href="
	* http://www.cs.princeton.edu/gfx/pubs/Sander_2007_%3ETR/tipsy.pdf">this
	* paper</a>).
	*
	* If you intend to render huge models in hardware, this step might
	* be of interest to you. The <tt>#AI_CONFIG_PP_ICL_PTCACHE_SIZE</tt>
	* importer property can be used to fine-tune the cache optimization.
	*/
    ImproveCacheLocality,
    /** <hr>Searches for redundant/unreferenced materials and removes them.
	*
	* This is especially useful in combination with the
	* #aiProcess_PreTransformVertices and #aiProcess_OptimizeMeshes flags.
	* Both join small meshes with equal characteristics, but they can't do
	* their work if two meshes have different materials. Because several
	* material settings are lost during Assimp's import filters,
	* (and because many exporters don't check for redundant materials), huge
	* models often have materials which are are defined several times with
	* exactly the same settings.
	*
	* Several material settings not contributing to the final appearance of
	* a surface are ignored in all comparisons (e.g. the material name).
	* So, if you're passing additional information through the
	* content pipeline (probably using *magic* material names), don't
	* specify this flag. Alternatively take a look at the
	* <tt>#AI_CONFIG_PP_RRM_EXCLUDE_LIST</tt> importer property.
	*/
    RemoveRedundantMaterials,
    /** <hr>This step tries to determine which meshes have normal vectors
	* that are facing inwards and inverts them.
	*
	* The algorithm is simple but effective:
	* the bounding box of all vertices + their normals is compared against
	* the volume of the bounding box of all vertices without their normals.
	* This works well for most objects, problems might occur with planar
	* surfaces. However, the step tries to filter such cases.
	* The step inverts all in-facing normals. Generally it is recommended
	* to enable this step, although the result is not always correct.
	*/
    FixInfacingNormals,
    /**
	* This step generically populates aiBone->mArmature and aiBone->mNode generically
	* The point of these is it saves you later having to calculate these elements
	* This is useful when handling rest information or skin information
	* If you have multiple armatures on your models we strongly recommend enabling this
	* Instead of writing your own multi-root, multi-armature lookups we have done the
	* hard work for you :)
	*/
    PopulateArmatureData,
    /** <hr>This step splits meshes with more than one primitive type in
	*  homogeneous sub-meshes.
	*
	*  The step is executed after the triangulation step. After the step
	*  returns, just one bit is set in aiMesh::mPrimitiveTypes. This is
	*  especially useful for real-time rendering where point and line
	*  primitives are often ignored or rendered separately.
	*  You can use the <tt>#AI_CONFIG_PP_SBP_REMOVE</tt> importer property to
	*  specify which primitive types you need. This can be used to easily
	*  exclude lines and points, which are rarely used, from the import.
	*/
    SortByPType,
    /** <hr>This step searches all meshes for degenerate primitives and
	*  converts them to proper lines or points.
	*
	* A face is 'degenerate' if one or more of its points are identical.
	* To have the degenerate stuff not only detected and collapsed but
	* removed, try one of the following procedures:
	* <br><b>1.</b> (if you support lines and points for rendering but don't
	*    want the degenerates)<br>
	* <ul>
	*   <li>Specify the #aiProcess_FindDegenerates flag.
	*   </li>
	*   <li>Set the <tt>#AI_CONFIG_PP_FD_REMOVE</tt> importer property to
	*       1. This will cause the step to remove degenerate triangles from the
	*       import as soon as they're detected. They won't pass any further
	*       pipeline steps.
	*   </li>
	* </ul>
	* <br><b>2.</b>(if you don't support lines and points at all)<br>
	* <ul>
	*   <li>Specify the #aiProcess_FindDegenerates flag.
	*   </li>
	*   <li>Specify the #aiProcess_SortByPType flag. This moves line and
	*     point primitives to separate meshes.
	*   </li>
	*   <li>Set the <tt>#AI_CONFIG_PP_SBP_REMOVE</tt> importer property to
	*       @code aiPrimitiveType_POINT | aiPrimitiveType_LINE
	*       @endcode to cause SortByPType to reject point
	*       and line meshes from the scene.
	*   </li>
	* </ul>
	*
	* This step also removes very small triangles with a surface area smaller
	* than 10^-6. If you rely on having these small triangles, or notice holes
	* in your model, set the property <tt>#AI_CONFIG_PP_FD_CHECKAREA</tt> to
	* false.
	* @note Degenerate polygons are not necessarily evil and that's why
	* they're not removed by default. There are several file formats which
	* don't support lines or points, and some exporters bypass the
	* format specification and write them as degenerate triangles instead.
	*/
    FindDegenerates,
    /** <hr>This step searches all meshes for invalid data, such as zeroed
	*  normal vectors or invalid UV coords and removes/fixes them. This is
	*  intended to get rid of some common exporter errors.
	*
	* This is especially useful for normals. If they are invalid, and
	* the step recognizes this, they will be removed and can later
	* be recomputed, i.e. by the #aiProcess_GenSmoothNormals flag.<br>
	* The step will also remove meshes that are infinitely small and reduce
	* animation tracks consisting of hundreds if redundant keys to a single
	* key. The <tt>AI_CONFIG_PP_FID_ANIM_ACCURACY</tt> config property decides
	* the accuracy of the check for duplicate animation tracks.
	*/
    FindInvalidData,
    /** <hr>This step converts non-UV mappings (such as spherical or
	*  cylindrical mapping) to proper texture coordinate channels.
	*
	* Most applications will support UV mapping only, so you will
	* probably want to specify this step in every case. Note that Assimp is not
	* always able to match the original mapping implementation of the
	* 3D app which produced a model perfectly. It's always better to let the
	* modelling app compute the UV channels - 3ds max, Maya, Blender,
	* LightWave, and Modo do this for example.
	*
	* @note If this step is not requested, you'll need to process the
	* <tt>#AI_MATKEY_MAPPING</tt> material property in order to display all assets
	* properly.
	*/
    GenUVCoords,
    /** <hr>This step applies per-texture UV transformations and bakes
	*  them into stand-alone vtexture coordinate channels.
	*
	* UV transformations are specified per-texture - see the
	* <tt>#AI_MATKEY_UVTRANSFORM</tt> material key for more information.
	* This step processes all textures with
	* transformed input UV coordinates and generates a new (pre-transformed) UV channel
	* which replaces the old channel. Most applications won't support UV
	* transformations, so you will probably want to specify this step.
	*
	* @note UV transformations are usually implemented in real-time apps by
	* transforming texture coordinates at vertex shader stage with a 3x3
	* (homogeneous) transformation matrix.
	*/
    TransformUVCoords,
    /** <hr>This step searches for duplicate meshes and replaces them
	*  with references to the first mesh.
	*
	*  This step takes a while, so don't use it if speed is a concern.
	*  Its main purpose is to workaround the fact that many export
	*  file formats don't support instanced meshes, so exporters need to
	*  duplicate meshes. This step removes the duplicates again. Please
	*  note that Assimp does not currently support per-node material
	*  assignment to meshes, which means that identical meshes with
	*  different materials are currently *not* joined, although this is
	*  planned for future versions.
	*/
    FindInstances,
    /** <hr>A post-processing step to reduce the number of meshes.
	*
	*  This will, in fact, reduce the number of draw calls.
	*
	*  This is a very effective optimization and is recommended to be used
	*  together with #aiProcess_OptimizeGraph, if possible. The flag is fully
	*  compatible with both #aiProcess_SplitLargeMeshes and #aiProcess_SortByPType.
	*/
    OptimizeMeshes,
    /** <hr>A post-processing step to optimize the scene hierarchy.
	*
	*  Nodes without animations, bones, lights or cameras assigned are
	*  collapsed and joined.
	*
	*  Node names can be lost during this step. If you use special 'tag nodes'
	*  to pass additional information through your content pipeline, use the
	*  <tt>#AI_CONFIG_PP_OG_EXCLUDE_LIST</tt> importer property to specify a
	*  list of node names you want to be kept. Nodes matching one of the names
	*  in this list won't be touched or modified.
	*
	*  Use this flag with caution. Most simple files will be collapsed to a
	*  single node, so complex hierarchies are usually completely lost. This is not
	*  useful for editor environments, but probably a very effective
	*  optimization if you just want to get the model data, convert it to your
	*  own format, and render it as fast as possible.
	*
	*  This flag is designed to be used with #aiProcess_OptimizeMeshes for best
	*  results.
	*
	*  @note 'Crappy' scenes with thousands of extremely small meshes packed
	*  in deeply nested nodes exist for almost all file formats.
	*  #aiProcess_OptimizeMeshes in combination with #aiProcess_OptimizeGraph
	*  usually fixes them all and makes them renderable.
	*/
    OptimizeGraph,
    /** <hr>This step flips all UV coordinates along the y-axis and adjusts
	* material settings and bitangents accordingly.
	*
	* <b>Output UV coordinate system:</b>
	* @code
	* 0x|0y ---------- 1x|0y
	* |                 |
	* |                 |
	* |                 |
	* 0x|1y ---------- 1x|1y
	* @endcode
	*
	* You'll probably want to consider this flag if you use Direct3D for
	* rendering. The #aiProcess_ConvertToLeftHanded flag supersedes this
	* setting and bundles all conversions typically required for D3D-based
	* applications.
	*/
    FlipUVs,
    /** <hr>This step adjusts the output face winding order to be CW.
	*
	* The default face winding order is counter clockwise (CCW).
	*
	* <b>Output face order:</b>
	* @code
	*       x2
	*
	*                         x0
	*  x1
	* @endcode
	*/
    FlipWindingOrder,
    /** <hr>This step splits meshes with many bones into sub-meshes so that each
	* sub-mesh has fewer or as many bones as a given limit.
	*/
    SplitByBoneCount,
    /** <hr>This step removes bones losslessly or according to some threshold.
	*
	*  In some cases (i.e. formats that require it) exporters are forced to
	*  assign dummy bone weights to otherwise static meshes assigned to
	*  animated meshes. Full, weight-based skinning is expensive while
	*  animating nodes is extremely cheap, so this step is offered to clean up
	*  the data in that regard.
	*
	*  Use <tt>#AI_CONFIG_PP_DB_THRESHOLD</tt> to control this.
	*  Use <tt>#AI_CONFIG_PP_DB_ALL_OR_NONE</tt> if you want bones removed if and
	*  only if all bones within the scene qualify for removal.
	*/
    Debone,
    /** <hr>This step will perform a global scale of the model.
	*
	*  Some importers are providing a mechanism to define a scaling unit for the
	*  model. This post processing step can be used to do so. You need to get the
	*  global scaling from your importer settings like in FBX. Use the flag
	*  AI_CONFIG_GLOBAL_SCALE_FACTOR_KEY from the global property table to configure this.
	*
	*  Use <tt>#AI_CONFIG_GLOBAL_SCALE_FACTOR_KEY</tt> to setup the global scaling factor.
	*/
    GlobalScale,
    /** <hr>A postprocessing step to embed of textures.
	*
	*  This will remove external data dependencies for textures.
	*  If a texture's file does not exist at the specified path
	*  (due, for instance, to an absolute path generated on another system),
	*  it will check if a file with the same name exists at the root folder
	*  of the imported model. And if so, it uses that.
	*/
    EmbedTextures,
    // aiProcess_GenEntityMeshes = 0x100000,
    // aiProcess_OptimizeAnimations = 0x200000
    // aiProcess_FixTexturePaths = 0x200000
    ForceGenNormals,
    /** <hr>Drops normals for all faces of all meshes.
	*
	* This is ignored if no normals are present.
	* Face normals are shared between all points of a single face,
	* so a single point can have multiple normals, which
	* forces the library to duplicate vertices in some cases.
	* #aiProcess_JoinIdenticalVertices is *senseless* then.
	* This process gives sense back to aiProcess_JoinIdenticalVertices
	*/
    DropNormals,
    GenBoundingBoxes,
}

/** @brief Defines the flags for all possible post processing steps.
*
*  @note Some steps are influenced by properties set on the Assimp::Importer itself
*
*  @see Assimp::Importer::ReadFile()
*  @see Assimp::Importer::SetPropertyInteger()
*  @see aiImportFile
*  @see aiImportFileEx
*/
Post_Process_Steps :: bit_set[Post_Process]

ConvertToLeftHanded: Post_Process_Steps : {.MakeLeftHanded, .FlipUVs, .FlipWindingOrder}

TargetRealtime_Fast: Post_Process_Steps : {
    .CalcTangentSpace,
    .GenNormals,
    .JoinIdenticalVertices,
    .Triangulate,
    .GenUVCoords,
    .SortByPType,
}

TargetRealtime_Quality: Post_Process_Steps : {
    .CalcTangentSpace,
    .GenSmoothNormals,
    .JoinIdenticalVertices,
    .ImproveCacheLocality,
    .LimitBoneWeights,
    .RemoveRedundantMaterials,
    .SplitLargeMeshes,
    .Triangulate,
    .GenUVCoords,
    .SortByPType,
    .FindDegenerates,
    .FindInvalidData,
}

TargetRealtime_MaxQuality: Post_Process_Steps :
    TargetRealtime_Quality | {.FindInstances, .ValidateDataStructure, .OptimizeMeshes}

/** @brief Enumerates components of the aiScene and aiMesh data structures
*  that can be excluded from the import using the #aiProcess_RemoveComponent step.
*
*  See the documentation to #aiProcess_RemoveComponent for more details.
*/
Raw_Component :: enum c.int {
    normals = 1,
    tangents_and_bitangents,
    /** ALL color sets
	* Use aiComponent_COLORn(N) to specify the N'th set */
    colors,
    /** ALL texture UV sets
	* aiComponent_TEXCOORDn(N) to specify the N'th set  */
    texcoords,
    /** Removes all bone weights from all meshes.
	* The scenegraph nodes corresponding to the bones are NOT removed.
	* use the #aiProcess_OptimizeGraph step to do this */
    boneweights,

    /** Removes all node animations (aiScene::mAnimations).
	* The corresponding scenegraph nodes are NOT removed.
	* use the #aiProcess_OptimizeGraph step to do this */
    animations,

    /** Removes all embedded textures (aiScene::mTextures) */
    textures,

    /** Removes all light sources (aiScene::mLights).
	* The corresponding scenegraph nodes are NOT removed.
	* use the #aiProcess_OptimizeGraph step to do this */
    lights,

    /** Removes all cameras (aiScene::mCameras).
	* The corresponding scenegraph nodes are NOT removed.
	* use the #aiProcess_OptimizeGraph step to do this */
    cameras,

    /** Removes all meshes (aiScene::mMeshes). */
    meshes,

    /** Removes all materials. One default material will
	* be generated, so aiScene::mNumMaterials will be 1. */
    materials,
}
// TODO: apparently this can be whatever?
Component :: bit_set[Raw_Component]

// Remove a specific color channel 'n'
Component_COLORSn :: proc(n: uint) -> uint {
    return 1 << (n + 20)
}

// Remove a specific UV channel 'n'
Component_TEXCOORDSn :: proc(n: uint) -> uint {
    return 1 << (n + 25)
}

UVTrafo :: enum c.int {
    scaling,
    rotation,
    translation,
}
UVTrafos :: bit_set[UVTrafo]
UVTrafo_ALL: bit_set[UVTrafo] : ~{}

AABB :: struct {
    min: Vector3d,
    max: Vector3d,
}

/**
* Enum used to distinguish data types
*/
Metadata_Type :: enum c.int {
    BOOL       = 0,
    INT32      = 1,
    UINT64     = 2,
    FLOAT      = 3,
    DOUBLE     = 4,
    AISTRING   = 5,
    AIVECTOR3D = 6,
    AIMETADATA = 7,
    INT64      = 8,
    UINT32     = 9,
    META_MAX   = 10,
}

/**
* Metadata entry
*
* The type field uniquely identifies the underlying type of the data field
*/
Metadata_Entry :: struct {
    type: Metadata_Type,
    data: rawptr,
}

/**
* Container for holding metadata.
*
* Metadata is a key-value store using string keys and values.
*/
Metadata :: struct {
    /** Length of the mKeys and mValues arrays, respectively */
    numProperties: u32,

    /** Arrays of keys, may not be NULL. Entries in this array may not be NULL as well. */
    keys:          ^String,

    /** Arrays of values, may not be NULL. Entries in this array may be NULL if the
	* corresponding property key has no assigned value. */
    values:        ^Metadata_Entry,
}


Vector2d :: [2]f32
Vector3d :: [3]f32
Matrix3x3 :: matrix[3, 3]f32
Matrix4x4 :: matrix[4, 4]f32
Quaternion :: quaternion128

Color4d :: [4]f32

MAXLEN :: 1024

/** Represents a plane in a three-dimensional, euclidean space
*/
Plane :: struct {
    //! Plane equation
    a, b, _c, d: f32,
}

/** Represents a ray
*/
Ray :: struct {
    //! Position and direction of the ray
    pos, dir: Vector3d,
}

/** Represents a color in Red-Green-Blue space.
*/
Color3d :: struct {
    //! Red, green and blue color values
    r, g, b: f32,
}

/**
* @brief Represents an UTF-8 string, zero byte terminated.
*
*  The character set of an aiString is explicitly defined to be UTF-8. This Unicode
*  transformation was chosen in the belief that most strings in 3d files are limited
*  to ASCII, thus the character set needed to be strictly ASCII compatible.
*
*  Most text file loaders provide proper Unicode input file handling, special unicode
*  characters are correctly transcoded to UTF8 and are kept throughout the libraries'
*  import pipeline.
*
*  For most applications, it will be absolutely sufficient to interpret the
*  aiString as ASCII data and work with it as one would work with a plain char*.
*  Windows users in need of proper support for i.e asian characters can use the
*  MultiByteToWideChar(), WideCharToMultiByte() WinAPI functionality to convert the
*  UTF-8 strings to their working character set (i.e. MBCS, WideChar).
*
*  We use this representation instead of std::string to be C-compatible. The
*  (binary) length of such a string is limited to AI_MAXLEN characters (including the
*  the terminating zero).
*/
String :: struct {
    /** Binary length of the string excluding the terminal 0. This is NOT the
	*  logical length of strings containing UTF-8 multi-byte sequences! It's
	*  the number of bytes from the beginning of the string to its end.*/
    length: u32,

    /** String buffer. Size limit is AI_MAXLEN */
    data:   [1024]u8,
}

/** Standard return type for some library functions.
* Rarely used, and if, mostly in the C API.
*/
Return :: enum c.int {
    /** Indicates that a function was successful */
    SUCCESS     = 0,

    /** Indicates that a function failed */
    FAILURE     = -1,

    /** Indicates that not enough memory was available
	* to perform the requested operation
	*/
    OUTOFMEMORY = -3,
}

/** Seek origins (for the virtual file system API).
*  Much cooler than using SEEK_SET, SEEK_CUR or SEEK_END.
*/
Origin :: enum c.int {
    /** Beginning of the file */
    SET = 0,

    /** Current position of the file pointer */
    CUR = 1,

    /** End of the file, offsets must be negative */
    END = 2,
}

/** @brief Enumerates predefined log streaming destinations.
*  Logging to these streams can be enabled with a single call to
*   #LogStream::createDefaultStream.
*/
Default_Log_Stream :: enum c.int {
    /** Stream the log to a file */
    FILE     = 1,

    /** Stream the log to std::cout */
    STDOUT   = 2,

    /** Stream the log to std::cerr */
    STDERR   = 4,

    /** MSVC only: Stream the log the the debugger
	* (this relies on OutputDebugString from the Win32 SDK)
	*/
    DEBUGGER = 8,
}

/** Stores the memory requirements for different components (e.g. meshes, materials,
*  animations) of an import. All sizes are in bytes.
*  @see Importer::GetMemoryRequirements()
*/
Memory_Info :: struct {
    /** Storage allocated for texture data */
    textures:   u32,

    /** Storage allocated for material data  */
    materials:  u32,

    /** Storage allocated for mesh data */
    meshes:     u32,

    /** Storage allocated for node data */
    nodes:      u32,

    /** Storage allocated for animation data */
    animations: u32,

    /** Storage allocated for camera data */
    cameras:    u32,

    /** Storage allocated for light data */
    lights:     u32,

    /** Total storage allocated for the full import. */
    total:      u32,
}

/**
*  @brief  Type to store a in-memory data buffer.
*/
Buffer :: struct {
    data: cstring, ///< Begin poiner
    end:  cstring, ///< End pointer
}

/** @brief Helper structure to represent a texel in a ARGB8888 format
*
*  Used by aiTexture.
*/
Texel :: [4]u8

HINTMAXTEXTURELEN :: 9

/** Helper structure to describe an embedded texture
*
* Normally textures are contained in external files but some file formats embed
* them directly in the model file. There are two types of embedded textures:
* 1. Uncompressed textures. The color data is given in an uncompressed format.
* 2. Compressed textures stored in a file format like png or jpg. The raw file
* bytes are given so the application must utilize an image decoder (e.g. DevIL) to
* get access to the actual color data.
*
* Embedded textures are referenced from materials using strings like "*0", "*1", etc.
* as the texture paths (a single asterisk character followed by the
* zero-based index of the texture in the aiScene::mTextures array).
*/
Texture :: struct {
    /** Width of the texture, in pixels
	*
	* If mHeight is zero the texture is compressed in a format
	* like JPEG. In this case mWidth specifies the size of the
	* memory area pcData is pointing to, in bytes.
	*/
    width:         u32,

    /** Height of the texture, in pixels
	*
	* If this value is zero, pcData points to an compressed texture
	* in any format (e.g. JPEG).
	*/
    height:        u32,
    achFormatHint: [9]u8, // 8 for string + 1 for terminator.

    /** Data of the texture.
	*
	* Points to an array of mWidth * mHeight aiTexel's.
	* The format of the texture data shall always be ARGB8888 if the texture-hint of the type is empty.
	* If the hint is not empty you can interpret the format by looking into this hint.
	* make the implementation for user of the library as easy
	* as possible. If mHeight = 0 this is a pointer to a memory
	* buffer of size mWidth containing the compressed texture
	* data. Good luck, have fun!
	*/
    pcData:        ^Texel,

    /** Texture original filename
	*
	* Used to get the texture reference
	*/
    filename:      String,
}

// Name for default materials (2nd is used if meshes have UV coords)
DEFAULT_MATERIAL_NAME :: "DefaultMaterial"

/** @brief Defines how the Nth texture of a specific type is combined with
*  the result of all previous layers.
*
*  Example (left: key, right: value): <br>
*  @code
*  DiffColor0     - gray
*  DiffTextureOp0 - aiTextureOpMultiply
*  DiffTexture0   - tex1.png
*  DiffTextureOp0 - aiTextureOpAdd
*  DiffTexture1   - tex2.png
*  @endcode
*  Written as equation, the final diffuse term for a specific pixel would be:
*  @code
*  diffFinal = DiffColor0 * sampleTex(DiffTexture0,UV0) +
*     sampleTex(DiffTexture1,UV0) * diffContrib;
*  @endcode
*  where 'diffContrib' is the intensity of the incoming light for that pixel.
*/
Texture_Op :: enum c.int {
    /** T = T1 * T2 */
    Multiply  = 0,

    /** T = T1 + T2 */
    Add       = 1,

    /** T = T1 - T2 */
    Subtract  = 2,

    /** T = T1 / T2 */
    Divide    = 3,

    /** T = (T1 + T2) - (T1 * T2) */
    SmoothAdd = 4,

    /** T = T1 + (T2-0.5) */
    SignedAdd = 5,
}

/** @brief Defines how UV coordinates outside the [0...1] range are handled.
*
*  Commonly referred to as 'wrapping mode'.
*/
Texture_Map_Mode :: enum c.int {
    /** A texture coordinate u|v is translated to u%1|v%1
	*/
    Wrap   = 0,

    /** Texture coordinates outside [0...1]
	*  are clamped to the nearest valid value.
	*/
    Clamp  = 1,

    /** If the texture coordinates for a pixel are outside [0...1]
	*  the texture is not applied to that pixel
	*/
    Decal  = 3,

    /** A texture coordinate u|v becomes u%1|v%1 if (u-(u%1))%2 is zero and
	*  1-(u%1)|1-(v%1) otherwise
	*/
    Mirror = 2,
}

/** @brief Defines how the mapping coords for a texture are generated.
*
*  Real-time applications typically require full UV coordinates, so the use of
*  the aiProcess_GenUVCoords step is highly recommended. It generates proper
*  UV channels for non-UV mapped objects, as long as an accurate description
*  how the mapping should look like (e.g spherical) is given.
*  See the #AI_MATKEY_MAPPING property for more details.
*/
Texture_Mapping :: enum c.int {
    /** The mapping coordinates are taken from an UV channel.
	*
	*  #AI_MATKEY_UVWSRC property specifies from which UV channel
	*  the texture coordinates are to be taken from (remember,
	*  meshes can have more than one UV channel).
	*/
    UV       = 0,

    /** Spherical mapping */
    SPHERE   = 1,

    /** Cylindrical mapping */
    CYLINDER = 2,

    /** Cubic mapping */
    BOX      = 3,

    /** Planar mapping */
    PLANE    = 4,

    /** Undefined mapping. Have fun. */
    OTHER    = 5,
}

/** @brief Defines the purpose of a texture
*
*  This is a very difficult topic. Different 3D packages support different
*  kinds of textures. For very common texture types, such as bumpmaps, the
*  rendering results depend on implementation details in the rendering
*  pipelines of these applications. Assimp loads all texture references from
*  the model file and tries to determine which of the predefined texture
*  types below is the best choice to match the original use of the texture
*  as closely as possible.<br>
*
*  In content pipelines you'll usually define how textures have to be handled,
*  and the artists working on models have to conform to this specification,
*  regardless which 3D tool they're using.
*/
Texture_Type :: enum c.int {
    /** Dummy value.
	*
	*  No texture, but the value to be used as 'texture semantic'
	*  (#aiMaterialProperty::mSemantic) for all material properties
	*  *not* related to textures.
	*/
    NONE                    = 0,

    /** The texture is combined with the result of the diffuse
	*  lighting equation.
	*  OR
	*  PBR Specular/Glossiness
	*/
    DIFFUSE                 = 1,

    /** The texture is combined with the result of the specular
	*  lighting equation.
	*  OR
	*  PBR Specular/Glossiness
	*/
    SPECULAR                = 2,

    /** The texture is combined with the result of the ambient
	*  lighting equation.
	*/
    AMBIENT                 = 3,

    /** The texture is added to the result of the lighting
	*  calculation. It isn't influenced by incoming light.
	*/
    EMISSIVE                = 4,

    /** The texture is a height map.
	*
	*  By convention, higher gray-scale values stand for
	*  higher elevations from the base height.
	*/
    HEIGHT                  = 5,

    /** The texture is a (tangent space) normal-map.
	*
	*  Again, there are several conventions for tangent-space
	*  normal maps. Assimp does (intentionally) not
	*  distinguish here.
	*/
    NORMALS                 = 6,

    /** The texture defines the glossiness of the material.
	*
	*  The glossiness is in fact the exponent of the specular
	*  (phong) lighting equation. Usually there is a conversion
	*  function defined to map the linear color values in the
	*  texture to a suitable exponent. Have fun.
	*/
    SHININESS               = 7,

    /** The texture defines per-pixel opacity.
	*
	*  Usually 'white' means opaque and 'black' means
	*  'transparency'. Or quite the opposite. Have fun.
	*/
    OPACITY                 = 8,

    /** Displacement texture
	*
	*  The exact purpose and format is application-dependent.
	*  Higher color values stand for higher vertex displacements.
	*/
    DISPLACEMENT            = 9,

    /** Lightmap texture (aka Ambient Occlusion)
	*
	*  Both 'Lightmaps' and dedicated 'ambient occlusion maps' are
	*  covered by this material property. The texture contains a
	*  scaling value for the final color value of a pixel. Its
	*  intensity is not affected by incoming light.
	*/
    LIGHTMAP                = 10,

    /** Reflection texture
	*
	* Contains the color of a perfect mirror reflection.
	* Rarely used, almost never for real-time applications.
	*/
    REFLECTION              = 11,

    /** PBR Materials
	* PBR definitions from maya and other modelling packages now use this standard.
	* This was originally introduced around 2012.
	* Support for this is in game engines like Godot, Unreal or Unity3D.
	* Modelling packages which use this are very common now.
	*/
    BASE_COLOR              = 12,

    /** PBR Materials
	* PBR definitions from maya and other modelling packages now use this standard.
	* This was originally introduced around 2012.
	* Support for this is in game engines like Godot, Unreal or Unity3D.
	* Modelling packages which use this are very common now.
	*/
    NORMAL_CAMERA           = 13,

    /** PBR Materials
	* PBR definitions from maya and other modelling packages now use this standard.
	* This was originally introduced around 2012.
	* Support for this is in game engines like Godot, Unreal or Unity3D.
	* Modelling packages which use this are very common now.
	*/
    EMISSION_COLOR          = 14,

    /** PBR Materials
	* PBR definitions from maya and other modelling packages now use this standard.
	* This was originally introduced around 2012.
	* Support for this is in game engines like Godot, Unreal or Unity3D.
	* Modelling packages which use this are very common now.
	*/
    METALNESS               = 15,

    /** PBR Materials
	* PBR definitions from maya and other modelling packages now use this standard.
	* This was originally introduced around 2012.
	* Support for this is in game engines like Godot, Unreal or Unity3D.
	* Modelling packages which use this are very common now.
	*/
    DIFFUSE_ROUGHNESS       = 16,

    /** PBR Materials
	* PBR definitions from maya and other modelling packages now use this standard.
	* This was originally introduced around 2012.
	* Support for this is in game engines like Godot, Unreal or Unity3D.
	* Modelling packages which use this are very common now.
	*/
    AMBIENT_OCCLUSION       = 17,

    /** Unknown texture
	*
	*  A texture reference that does not match any of the definitions
	*  above is considered to be 'unknown'. It is still imported,
	*  but is excluded from any further post-processing.
	*/
    UNKNOWN                 = 18,

    /** Sheen
	* Generally used to simulate textiles that are covered in a layer of microfibers
	* eg velvet
	* https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Khronos/KHR_materials_sheen
	*/
    SHEEN                   = 19,

    /** Clearcoat
	* Simulates a layer of 'polish' or 'lacquer' layered on top of a PBR substrate
	* https://autodesk.github.io/standard-surface/#closures/coating
	* https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Khronos/KHR_materials_clearcoat
	*/
    CLEARCOAT               = 20,

    /** Transmission
	* Simulates transmission through the surface
	* May include further information such as wall thickness
	*/
    TRANSMISSION            = 21,

    /**
	* Maya material declarations
	*/
    MAYA_BASE               = 22,

    /**
	* Maya material declarations
	*/
    MAYA_SPECULAR           = 23,

    /**
	* Maya material declarations
	*/
    MAYA_SPECULAR_COLOR     = 24,

    /**
	* Maya material declarations
	*/
    MAYA_SPECULAR_ROUGHNESS = 25,

    /** Anisotropy
	* Simulates a surface with directional properties
	*/
    ANISOTROPY              = 26,

    /**
	* gltf material declarations
	* Refs: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#metallic-roughness-material
	*           "textures for metalness and roughness properties are packed together in a single
	*           texture called metallicRoughnessTexture. Its green channel contains roughness
	*           values and its blue channel contains metalness values..."
	*       https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#_material_pbrmetallicroughness_metallicroughnesstexture
	*           "The metalness values are sampled from the B channel. The roughness values are
	*           sampled from the G channel..."
	*/
    GLTF_METALLIC_ROUGHNESS = 27,
}

// TEXTURE_TYPE_MAX :: Texture_Type_Gltf_Metallic_Roughness

/** @brief Defines all shading models supported by the library
*
*  Property: #AI_MATKEY_SHADING_MODEL
*
*  The list of shading modes has been taken from Blender.
*  See Blender documentation for more information. The API does
*  not distinguish between "specular" and "diffuse" shaders (thus the
*  specular term for diffuse shading models like Oren-Nayar remains
*  undefined). <br>
*  Again, this value is just a hint. Assimp tries to select the shader whose
*  most common implementation matches the original rendering results of the
*  3D modeler which wrote a particular model as closely as possible.
*
*/
Shading_Mode :: enum c.int {
    /** Flat shading. Shading is done on per-face base,
	*  diffuse only. Also known as 'faceted shading'.
	*/
    Flat         = 1,

    /** Simple Gouraud shading.
	*/
    Gouraud      = 2,

    /** Phong-Shading -
	*/
    Phong        = 3,

    /** Phong-Blinn-Shading
	*/
    Blinn        = 4,

    /** Toon-Shading per pixel
	*
	*  Also known as 'comic' shader.
	*/
    Toon         = 5,

    /** OrenNayar-Shading per pixel
	*
	*  Extension to standard Lambertian shading, taking the
	*  roughness of the material into account
	*/
    OrenNayar    = 6,

    /** Minnaert-Shading per pixel
	*
	*  Extension to standard Lambertian shading, taking the
	*  "darkness" of the material into account
	*/
    Minnaert     = 7,

    /** CookTorrance-Shading per pixel
	*
	*  Special shader for metallic surfaces.
	*/
    CookTorrance = 8,

    /** No shading at all. Constant light influence of 1.0.
	* Also known as "Unlit"
	*/
    NoShading    = 9,
    Unlit        = 9, // Alias

    /** Fresnel shading
	*/
    Fresnel      = 10,

    /** Physically-Based Rendering (PBR) shading using
	* Bidirectional scattering/reflectance distribution function (BSDF/BRDF)
	* There are multiple methods under this banner, and model files may provide
	* data for more than one PBR-BRDF method.
	* Applications should use the set of provided properties to determine which
	* of their preferred PBR rendering methods are likely to be available
	* eg:
	* - If AI_MATKEY_METALLIC_FACTOR is set, then a Metallic/Roughness is available
	* - If AI_MATKEY_GLOSSINESS_FACTOR is set, then a Specular/Glossiness is available
	* Note that some PBR methods allow layering of techniques
	*/
    PBR_BRDF     = 11,
}

/**
*  @brief Defines some mixed flags for a particular texture.
*
*  Usually you'll instruct your cg artists how textures have to look like ...
*  and how they will be processed in your application. However, if you use
*  Assimp for completely generic loading purposes you might also need to
*  process these flags in order to display as many 'unknown' 3D models as
*  possible correctly.
*
*  This corresponds to the #AI_MATKEY_TEXFLAGS property.
*/
Texture_Flags :: enum c.int {
    /** The texture's color values have to be inverted (component-wise 1-n)
	*/
    Invert      = 1,

    /** Explicit request to the application to process the alpha channel
	*  of the texture.
	*
	*  Mutually exclusive with #aiTextureFlags_IgnoreAlpha. These
	*  flags are set if the library can say for sure that the alpha
	*  channel is used/is not used. If the model format does not
	*  define this, it is left to the application to decide whether
	*  the texture alpha channel - if any - is evaluated or not.
	*/
    UseAlpha    = 2,

    /** Explicit request to the application to ignore the alpha channel
	*  of the texture.
	*
	*  Mutually exclusive with #aiTextureFlags_UseAlpha.
	*/
    IgnoreAlpha = 4,
}

/**
*  @brief Defines alpha-blend flags.
*
*  If you're familiar with OpenGL or D3D, these flags aren't new to you.
*  They define *how* the final color value of a pixel is computed, basing
*  on the previous color at that pixel and the new color value from the
*  material.
*  The blend formula is:
*  @code
*    SourceColor * SourceBlend + DestColor * DestBlend
*  @endcode
*  where DestColor is the previous color in the frame-buffer at this
*  position and SourceColor is the material color before the transparency
*  calculation.<br>
*  This corresponds to the #AI_MATKEY_BLEND_FUNC property.
*/
Blend_Mode :: enum c.int {
    /**
	*  Formula:
	*  @code
	*  SourceColor*SourceAlpha + DestColor*(1-SourceAlpha)
	*  @endcode
	*/
    Default  = 0,

    /** Additive blending
	*
	*  Formula:
	*  @code
	*  SourceColor*1 + DestColor*1
	*  @endcode
	*/
    Additive = 1,
}

/**
*  @brief Defines how an UV channel is transformed.
*
*  This is just a helper structure for the #AI_MATKEY_UVTRANSFORM key.
*  See its documentation for more details.
*
*  Typically you'll want to build a matrix of this information. However,
*  we keep separate scaling/translation/rotation values to make it
*  easier to process and optimize UV transformations internally.
*/
Uvtransform :: struct {
    /** Translation on the u and v axes.
	*
	*  The default value is (0|0).
	*/
    translation: Vector2d,

    /** Scaling on the u and v axes.
	*
	*  The default value is (1|1).
	*/
    scaling:     Vector2d,

    /** Rotation - in counter-clockwise direction.
	*
	*  The rotation angle is specified in radians. The
	*  rotation center is 0.5f|0.5f. The default value
	*  0.f.
	*/
    rotation:    f32,
}

//! @cond AI_DOX_INCLUDE_INTERNAL
/**
*  @brief A very primitive RTTI system for the contents of material properties.
*/
Property_Type_Info :: enum c.int {
    /** Array of single-precision (32 Bit) floats
	*
	*  It is possible to use aiGetMaterialInteger[Array]() (or the C++-API
	*  aiMaterial::Get()) to query properties stored in floating-point format.
	*  The material system performs the type conversion automatically.
	*/
    Float   = 1,

    /** Array of double-precision (64 Bit) floats
	*
	*  It is possible to use aiGetMaterialInteger[Array]() (or the C++-API
	*  aiMaterial::Get()) to query properties stored in floating-point format.
	*  The material system performs the type conversion automatically.
	*/
    Double  = 2,

    /** The material property is an aiString.
	*
	*  Arrays of strings aren't possible, aiGetMaterialString() (or the
	*  C++-API aiMaterial::Get()) *must* be used to query a string property.
	*/
    String  = 3,

    /** Array of (32 Bit) integers
	*
	*  It is possible to use aiGetMaterialFloat[Array]() (or the C++-API
	*  aiMaterial::Get()) to query properties stored in integer format.
	*  The material system performs the type conversion automatically.
	*/
    Integer = 4,

    /** Simple binary buffer, content undefined. Not convertible to anything.
	*/
    Buffer  = 5,
}

/** @brief Data structure for a single material property
*
*  As an user, you'll probably never need to deal with this data structure.
*  Just use the provided aiGetMaterialXXX() or aiMaterial::Get() family
*  of functions to query material properties easily. Processing them
*  manually is faster, but it is not the recommended way. It isn't worth
*  the effort. <br>
*  Material property names follow a simple scheme:
*  @code
*    $<name>
*    ?<name>
*       A public property, there must be corresponding AI_MATKEY_XXX define
*       2nd: Public, but ignored by the #aiProcess_RemoveRedundantMaterials
*       post-processing step.
*    ~<name>
*       A temporary property for internal use.
*  @endcode
*  @see aiMaterial
*/
Material_Property :: struct {
    /** Specifies the name of the property (key)
	*  Keys are generally case insensitive.
	*/
    key:        String,

    /** Textures: Specifies their exact usage semantic.
	* For non-texture properties, this member is always 0
	* (or, better-said, #aiTextureType_NONE).
	*/
    semantic:   u32,

    /** Textures: Specifies the index of the texture.
	*  For non-texture properties, this member is always 0.
	*/
    index:      u32,

    /** Size of the buffer mData is pointing to, in bytes.
	*  This value may not be 0.
	*/
    dataLength: u32,

    /** Type information for the property.
	*
	* Defines the data layout inside the data buffer. This is used
	* by the library internally to perform debug checks and to
	* utilize proper type conversions.
	* (It's probably a hacky solution, but it works.)
	*/
    type:       Property_Type_Info,

    /** Binary buffer to hold the property's value.
	* The size of the buffer is always mDataLength.
	*/
    data:       cstring,
}

Material :: struct {
    /** List of all material properties loaded. */
    properties:    ^^Material_Property,

    /** Number of properties in the data base */
    numProperties: u32,

    /** Storage allocated */
    numAllocated:  u32,
}

// Pure key names for all texture-related properties
//! @cond MATS_DOC_FULL
TEXTURE_BASE :: "$tex.file"
UVWSRC_BASE :: "$tex.uvwsrc"
TEXOP_BASE :: "$tex.op"
MAPPING_BASE :: "$tex.mapping"
TEXBLEND_BASE :: "$tex.blend"
MAPPINGMODE_U_BASE :: "$tex.mapmodeu"
MAPPINGMODE_V_BASE :: "$tex.mapmodev"
TEXMAP_AXIS_BASE :: "$tex.mapaxis"
UVTRANSFORM_BASE :: "$tex.uvtrafo"
TEXFLAGS_BASE :: "$tex.flags"

/**
* A node in the imported hierarchy.
*
* Each node has name, a parent node (except for the root node),
* a transformation relative to its parent and possibly several child nodes.
* Simple file formats don't support hierarchical structures - for these formats
* the imported scene does consist of only a single root node without children.
*/
Node :: struct {
    /** The name of the node.
	*
	* The name might be empty (length of zero) but all nodes which
	* need to be referenced by either bones or animations are named.
	* Multiple nodes may have the same name, except for nodes which are referenced
	* by bones (see #aiBone and #aiMesh::mBones). Their names *must* be unique.
	*
	* Cameras and lights reference a specific node by name - if there
	* are multiple nodes with this name, they are assigned to each of them.
	* <br>
	* There are no limitations with regard to the characters contained in
	* the name string as it is usually taken directly from the source file.
	*
	* Implementations should be able to handle tokens such as whitespace, tabs,
	* line feeds, quotation marks, ampersands etc.
	*
	* Sometimes assimp introduces new nodes not present in the source file
	* into the hierarchy (usually out of necessity because sometimes the
	* source hierarchy format is simply not compatible). Their names are
	* surrounded by @verbatim <> @endverbatim e.g.
	*  @verbatim<DummyRootNode> @endverbatim.
	*/
    name:           String,

    /** The transformation relative to the node's parent. */
    transformation: Matrix4x4,

    /** Parent node. nullptr if this node is the root node. */
    parent:         ^Node,

    /** The number of child nodes of this node. */
    numChildren:    u32,

    /** The child nodes of this node. nullptr if mNumChildren is 0. */
    children:       ^^Node,

    /** The number of meshes of this node. */
    numMeshes:      u32,

    /** The meshes of this node. Each entry is an index into the
	* mesh list of the #aiScene.
	*/
    meshes:         ^u32,

    /** Metadata associated with this node or nullptr if there is no metadata.
	*  Whether any metadata is generated depends on the source file format. See the
	* @link importer_notes @endlink page for more information on every source file
	* format. Importers that don't document any metadata don't write any.
	*/
    metaData:       ^Metadata,
}
Scene_Flag :: enum c.int {
    /**
 * Specifies that the scene data structure that was imported is not complete.
 * This flag bypasses some internal validations and allows the import
 * of animation skeletons, material libraries or camera animation paths
 * using Assimp. Most applications won't support such data.
 */
    incomplete,

    /**
 * This flag is set by the validation postprocess-step (aiPostProcess_ValidateDS)
 * if the validation is successful. In a validated scene you can be sure that
 * any cross references in the data structure (e.g. vertex indices) are valid.
 */
    validated,

    /**
 * This flag is set by the validation postprocess-step (aiPostProcess_ValidateDS)
 * if the validation is successful but some issues have been found.
 * This can for example mean that a texture that does not exist is referenced
 * by a material or that the bone weights for a vertex don't sum to 1.0 ... .
 * In most cases you should still be able to use the import. This flag could
 * be useful for applications which don't capture Assimp's log output.
 */
    validation_warning,

    /**
 * This flag is currently only set by the aiProcess_JoinIdenticalVertices step.
 * It indicates that the vertices of the output meshes aren't in the internal
 * verbose format anymore. In the verbose format all vertices are unique,
 * no vertex is ever referenced by more than one face.
 */
    non_verbose_format,

    /**
 * Denotes pure height-map terrain data. Pure terrains usually consist of quads,
 * sometimes triangles, in a regular grid. The x,y coordinates of all vertex
 * positions refer to the x,y coordinates on the terrain height map, the z-axis
 * stores the elevation at a specific point.
 *
 * TER (Terragen) and HMP (3D Game Studio) are height map formats.
 * @note Assimp is probably not the best choice for loading *huge* terrains -
 * fully triangulated data takes extremely much free store and should be avoided
 * as long as possible (typically you'll do the triangulation when you actually
 * need to render it).
 */
    terrain,

    /**
 * Specifies that the scene data can be shared between structures. For example:
 * one vertex in few faces. \ref AI_SCENE_FLAGS_NON_VERBOSE_FORMAT can not be
 * used for this because \ref AI_SCENE_FLAGS_NON_VERBOSE_FORMAT has internal
 * meaning about postprocessing steps.
 */
    allow_shared,
}
Scene_Flags :: bit_set[Scene_Flag]


/** The root structure of the imported data.
*
*  Everything that was imported from the given file can be accessed from here.
*  Objects of this class are generally maintained and owned by Assimp, not
*  by the caller. You shouldn't want to instance it, nor should you ever try to
*  delete a given scene on your own.
*/
Scene :: struct {
    /** Any combination of the AI_SCENE_FLAGS_XXX flags. By default
	* this value is 0, no flags are set. Most applications will
	* want to reject all scenes with the AI_SCENE_FLAGS_INCOMPLETE
	* bit set.
	*/
    flags:         u32,

    /** The root node of the hierarchy.
	*
	* There will always be at least the root node if the import
	* was successful (and no special flags have been set).
	* Presence of further nodes depends on the format and content
	* of the imported file.
	*/
    rootNode:      ^Node,

    /** The number of meshes in the scene. */
    numMeshes:     u32,

    /** The array of meshes.
	*
	* Use the indices given in the aiNode structure to access
	* this array. The array is mNumMeshes in size. If the
	* AI_SCENE_FLAGS_INCOMPLETE flag is not set there will always
	* be at least ONE material.
	*/
    meshes:        [^]^Mesh,

    /** The number of materials in the scene. */
    numMaterials:  u32,

    /** The array of materials.
	*
	* Use the index given in each aiMesh structure to access this
	* array. The array is mNumMaterials in size. If the
	* AI_SCENE_FLAGS_INCOMPLETE flag is not set there will always
	* be at least ONE material.
	*/
    materials:     [^]^Material,

    /** The number of animations in the scene. */
    numAnimations: u32,

    /** The array of animations.
	*
	* All animations imported from the given file are listed here.
	* The array is mNumAnimations in size.
	*/
    animations:    [^]^Animation,

    /** The number of textures embedded into the file */
    numTextures:   u32,

    /** The array of embedded textures.
	*
	* Not many file formats embed their textures into the file.
	* An example is Quake's MDL format (which is also used by
	* some GameStudio versions)
	*/
    textures:      [^]^Texture,

    /** The number of light sources in the scene. Light sources
	* are fully optional, in most cases this attribute will be 0
	*/
    numLights:     u32,

    /** The array of light sources.
	*
	* All light sources imported from the given file are
	* listed here. The array is mNumLights in size.
	*/
    lights:        [^]^Light,

    /** The number of cameras in the scene. Cameras
	* are fully optional, in most cases this attribute will be 0
	*/
    numCameras:    u32,

    /** The array of cameras.
	*
	* All cameras imported from the given file are listed here.
	* The array is mNumCameras in size. The first camera in the
	* array (if existing) is the default camera view into
	* the scene.
	*/
    cameras:       [^]^Camera,

    /**
	*  @brief  The global metadata assigned to the scene itself.
	*
	*  This data contains global metadata which belongs to the scene like
	*  unit-conversions, versions, vendors or other model-specific data. This
	*  can be used to store format-specific metadata as well.
	*/
    metaData:      ^Metadata,

    /** The name of the scene itself.
	*/
    name:          String,
    numSkeletons:  u32,
    skeletons:     [^]^Skeleton,
    private:       cstring,
}

/** @def AI_MAX_FACE_INDICES
 *  Maximum number of indices per face (polygon). */
MAX_FACE_INDICES :: 0x7fff

/** @def AI_MAX_BONE_WEIGHTS
 *  Maximum number of indices per face (polygon). */
MAX_BONE_WEIGHTS :: 0x7fffffff

/** @def AI_MAX_VERTICES
 *  Maximum number of vertices per mesh.  */
MAX_VERTICES :: 0x7fffffff

/** @def AI_MAX_FACES
 *  Maximum number of faces per mesh. */
MAX_FACES :: 0x7fffffff

/** @def AI_MAX_NUMBER_OF_COLOR_SETS
 *  Supported number of vertex color sets per mesh. */
MAX_NUMBER_OF_COLOR_SETS :: 0x8

/** @def AI_MAX_NUMBER_OF_TEXTURECOORDS
 *  Supported number of texture coord sets (UV(W) channels) per mesh */
MAX_NUMBER_OF_TEXTURECOORDS :: 0x8

/**
* @brief A single face in a mesh, referring to multiple vertices.
*
* If mNumIndices is 3, we call the face 'triangle', for mNumIndices > 3
* it's called 'polygon' (hey, that's just a definition!).
* <br>
* aiMesh::mPrimitiveTypes can be queried to quickly examine which types of
* primitive are actually present in a mesh. The #aiProcess_SortByPType flag
* executes a special post-processing algorithm which splits meshes with
* *different* primitive types mixed up (e.g. lines and triangles) in several
* 'clean' sub-meshes. Furthermore there is a configuration option (
* #AI_CONFIG_PP_SBP_REMOVE) to force #aiProcess_SortByPType to remove
* specific kinds of primitives from the imported scene, completely and forever.
* In many cases you'll probably want to set this setting to
* @code
* aiPrimitiveType_LINE|aiPrimitiveType_POINT
* @endcode
* Together with the #aiProcess_Triangulate flag you can then be sure that
* #aiFace::mNumIndices is always 3.
* @note Take a look at the @link data Data Structures page @endlink for
* more information on the layout and winding order of a face.
*/
Face :: struct {
    //! Number of indices defining this face.
    //! The maximum value for this member is #AI_MAX_FACE_INDICES.
    numIndices: u32,

    //! Pointer to the indices array. Size of the array is given in numIndices.
    indices:    ^u32,
}

/** @brief A single influence of a bone on a vertex.
*/
Vertex_Weight :: struct {
    //! Index of the vertex which is influenced by the bone.
    vertexId: u32,

    //! The strength of the influence in the range (0...1).
    //! The influence from all bones at one vertex amounts to 1.
    weight:   f32,
}

/** @brief A single bone of a mesh.
*
*  A bone has a name by which it can be found in the frame hierarchy and by
*  which it can be addressed by animations. In addition it has a number of
*  influences on vertices, and a matrix relating the mesh position to the
*  position of the bone at the time of binding.
*/
Bone :: struct {
    /**
	* The name of the bone.
	*/
    name:         String,

    /**
	* The number of vertices affected by this bone.
	* The maximum value for this member is #AI_MAX_BONE_WEIGHTS.
	*/
    numWeights:   u32,

    /**
	* The bone armature node - used for skeleton conversion
	* you must enable aiProcess_PopulateArmatureData to populate this
	*/
    armature:     ^Node,

    /**
	* The bone node in the scene - used for skeleton conversion
	* you must enable aiProcess_PopulateArmatureData to populate this
	*/
    node:         ^Node,

    /**
	* The influence weights of this bone, by vertex index.
	*/
    weights:      ^Vertex_Weight,

    /**
	* Matrix that transforms from mesh space to bone space in bind pose.
	*
	* This matrix describes the position of the mesh
	* in the local space of this bone when the skeleton was bound.
	* Thus it can be used directly to determine a desired vertex position,
	* given the world-space transform of the bone when animated,
	* and the position of the vertex in mesh space.
	*
	* It is sometimes called an inverse-bind matrix,
	* or inverse bind pose matrix.
	*/
    offsetMatrix: Matrix4x4,
}

/** @brief Enumerates the types of geometric primitives supported by Assimp.
*
*  @see aiFace Face data structure
*  @see aiProcess_SortByPType Per-primitive sorting of meshes
*  @see aiProcess_Triangulate Automatic triangulation
*  @see AI_CONFIG_PP_SBP_REMOVE Removal of specific primitive types.
*/
Primitive_Type :: enum c.int {
    /**
	* @brief A point primitive.
	*
	* This is just a single vertex in the virtual world,
	* #aiFace contains just one index for such a primitive.
	*/
    POINT            = 1,

    /**
	* @brief A line primitive.
	*
	* This is a line defined through a start and an end position.
	* #aiFace contains exactly two indices for such a primitive.
	*/
    LINE             = 2,

    /**
	* @brief A triangular primitive.
	*
	* A triangle consists of three indices.
	*/
    TRIANGLE         = 4,

    /**
	* @brief A higher-level polygon with more than 3 edges.
	*
	* A triangle is a polygon, but polygon in this context means
	* "all polygons that are not triangles". The "Triangulate"-Step
	* is provided for your convenience, it splits all polygons in
	* triangles (which are much easier to handle).
	*/
    POLYGON          = 8,

    /**
	* @brief A flag to determine whether this triangles only mesh is NGON encoded.
	*
	* NGON encoding is a special encoding that tells whether 2 or more consecutive triangles
	* should be considered as a triangle fan. This is identified by looking at the first vertex index.
	* 2 consecutive triangles with the same 1st vertex index are part of the same
	* NGON.
	*
	* At the moment, only quads (concave or convex) are supported, meaning that polygons are 'seen' as
	* triangles, as usual after a triangulation pass.
	*
	* To get an NGON encoded mesh, please use the aiProcess_Triangulate post process.
	*
	* @see aiProcess_Triangulate
	* @link https://github.com/KhronosGroup/glTF/pull/1620
	*/
    NGONEncodingFlag = 16,
}

/** @brief An AnimMesh is an attachment to an #aiMesh stores per-vertex
*  animations for a particular frame.
*
*  You may think of an #aiAnimMesh as a `patch` for the host mesh, which
*  replaces only certain vertex data streams at a particular time.
*  Each mesh stores n attached attached meshes (#aiMesh::mAnimMeshes).
*  The actual relationship between the time line and anim meshes is
*  established by #aiMeshAnim, which references singular mesh attachments
*  by their ID and binds them to a time offset.
*/
Anim_Mesh :: struct {
    /**Anim Mesh name */
    name:          String,

    /** Replacement for aiMesh::mVertices. If this array is non-nullptr,
	*  it *must* contain mNumVertices entries. The corresponding
	*  array in the host mesh must be non-nullptr as well - animation
	*  meshes may neither add or nor remove vertex components (if
	*  a replacement array is nullptr and the corresponding source
	*  array is not, the source data is taken instead)*/
    vertices:      ^Vector3d,

    /** Replacement for aiMesh::mNormals.  */
    normals:       ^Vector3d,

    /** Replacement for aiMesh::mTangents. */
    tangents:      ^Vector3d,

    /** Replacement for aiMesh::mBitangents. */
    bitangents:    ^Vector3d,

    /** Replacement for aiMesh::mColors */
    colors:        ^[8]Color4d,

    /** Replacement for aiMesh::mTextureCoords */
    textureCoords: ^[8]Vector3d,

    /** The number of vertices in the aiAnimMesh, and thus the length of all
	* the member arrays.
	*
	* This has always the same value as the mNumVertices property in the
	* corresponding aiMesh. It is duplicated here merely to make the length
	* of the member arrays accessible even if the aiMesh is not known, e.g.
	* from language bindings.
	*/
    numVertices:   u32,

    /**
	* Weight of the AnimMesh.
	*/
    weight:        f32,
}

/** @brief Enumerates the methods of mesh morphing supported by Assimp.
*/
Morphing_Method :: enum c.int {
    /** Morphing method to be determined */
    UNKNOWN          = 0,

    /** Interpolation between morph targets */
    VERTEX_BLEND     = 1,

    /** Normalized morphing between morph targets  */
    MORPH_NORMALIZED = 2,

    /** Relative morphing between morph targets  */
    MORPH_RELATIVE   = 3,
}

/** @brief A mesh represents a geometry or model with a single material.
*
* It usually consists of a number of vertices and a series of primitives/faces
* referencing the vertices. In addition there might be a series of bones, each
* of them addressing a number of vertices with a certain weight. Vertex data
* is presented in channels with each channel containing a single per-vertex
* information such as a set of texture coordinates or a normal vector.
* If a data pointer is non-null, the corresponding data stream is present.
* From C++-programs you can also use the comfort functions Has*() to
* test for the presence of various data streams.
*
* A Mesh uses only a single material which is referenced by a material ID.
* @note The mPositions member is usually not optional. However, vertex positions
* *could* be missing if the #AI_SCENE_FLAGS_INCOMPLETE flag is set in
* @code
* aiScene::mFlags
* @endcode
*/
Mesh :: struct {
    /**
	* Bitwise combination of the members of the #aiPrimitiveType enum.
	* This specifies which types of primitives are present in the mesh.
	* The "SortByPrimitiveType"-Step can be used to make sure the
	* output meshes consist of one primitive type each.
	*/
    primitiveTypes:     u32,

    /**
	* The number of vertices in this mesh.
	* This is also the size of all of the per-vertex data arrays.
	* The maximum value for this member is #AI_MAX_VERTICES.
	*/
    numVertices:        u32,

    /**
	* The number of primitives (triangles, polygons, lines) in this  mesh.
	* This is also the size of the mFaces array.
	* The maximum value for this member is #AI_MAX_FACES.
	*/
    numFaces:           u32,

    /**
	* @brief Vertex positions.
	*
	* This array is always present in a mesh. The array is
	* mNumVertices in size.
	*/
    vertices:           ^Vector3d,

    /**
	* @brief Vertex normals.
	*
	* The array contains normalized vectors, nullptr if not present.
	* The array is mNumVertices in size. Normals are undefined for
	* point and line primitives. A mesh consisting of points and
	* lines only may not have normal vectors. Meshes with mixed
	* primitive types (i.e. lines and triangles) may have normals,
	* but the normals for vertices that are only referenced by
	* point or line primitives are undefined and set to QNaN (WARN:
	* qNaN compares to inequal to *everything*, even to qNaN itself.
	* Using code like this to check whether a field is qnan is:
	* @code
	* #define IS_QNAN(f) (f != f)
	* @endcode
	* still dangerous because even 1.f == 1.f could evaluate to false! (
	* remember the subtleties of IEEE754 artithmetics). Use stuff like
	* @c fpclassify instead.
	* @note Normal vectors computed by Assimp are always unit-length.
	* However, this needn't apply for normals that have been taken
	* directly from the model file.
	*/
    normals:            ^Vector3d,

    /**
	* @brief Vertex tangents.
	*
	* The tangent of a vertex points in the direction of the positive
	* X texture axis. The array contains normalized vectors, nullptr if
	* not present. The array is mNumVertices in size. A mesh consisting
	* of points and lines only may not have normal vectors. Meshes with
	* mixed primitive types (i.e. lines and triangles) may have
	* normals, but the normals for vertices that are only referenced by
	* point or line primitives are undefined and set to qNaN.  See
	* the #mNormals member for a detailed discussion of qNaNs.
	* @note If the mesh contains tangents, it automatically also
	* contains bitangents.
	*/
    tangents:           ^Vector3d,

    /**
	* @brief Vertex bitangents.
	*
	* The bitangent of a vertex points in the direction of the positive
	* Y texture axis. The array contains normalized vectors, nullptr if not
	* present. The array is mNumVertices in size.
	* @note If the mesh contains tangents, it automatically also contains
	* bitangents.
	*/
    bitangents:         ^Vector3d,

    /**
	* @brief Vertex color sets.
	*
	* A mesh may contain 0 to #AI_MAX_NUMBER_OF_COLOR_SETS vertex
	* colors per vertex. nullptr if not present. Each array is
	* mNumVertices in size if present.
	*/
    colors:             ^[8]Color4d,

    /**
	* @brief Vertex texture coordinates, also known as UV channels.
	*
	* A mesh may contain 0 to AI_MAX_NUMBER_OF_TEXTURECOORDS channels per
	* vertex. Used and unused (nullptr) channels may go in any order.
	* The array is mNumVertices in size.
	*/
    textureCoords:      ^[8]Vector3d,

    /**
	* @brief Specifies the number of components for a given UV channel.
	*
	* Up to three channels are supported (UVW, for accessing volume
	* or cube maps). If the value is 2 for a given channel n, the
	* component p.z of mTextureCoords[n][p] is set to 0.0f.
	* If the value is 1 for a given channel, p.y is set to 0.0f, too.
	* @note 4D coordinates are not supported
	*/
    numUVComponents:    [8]u32,

    /**
	* @brief The faces the mesh is constructed from.
	*
	* Each face refers to a number of vertices by their indices.
	* This array is always present in a mesh, its size is given
	*  in mNumFaces. If the #AI_SCENE_FLAGS_NON_VERBOSE_FORMAT
	* is NOT set each face references an unique set of vertices.
	*/
    faces:              ^Face,

    /**
	* The number of bones this mesh contains. Can be 0, in which case the mBones array is nullptr.
	*/
    numBones:           u32,

    /**
	* @brief The bones of this mesh.
	*
	* A bone consists of a name by which it can be found in the
	* frame hierarchy and a set of vertex weights.
	*/
    bones:              ^^Bone,

    /**
	* @brief The material used by this mesh.
	*
	* A mesh uses only a single material. If an imported model uses
	* multiple materials, the import splits up the mesh. Use this value
	* as index into the scene's material list.
	*/
    materialIndex:      u32,

    /**
	*  Name of the mesh. Meshes can be named, but this is not a
	*  requirement and leaving this field empty is totally fine.
	*  There are mainly three uses for mesh names:
	*   - some formats name nodes and meshes independently.
	*   - importers tend to split meshes up to meet the
	*      one-material-per-mesh requirement. Assigning
	*      the same (dummy) name to each of the result meshes
	*      aids the caller at recovering the original mesh
	*      partitioning.
	*   - Vertex animations refer to meshes by their names.
	*/
    name:               String,

    /**
	* The number of attachment meshes.
	* Currently known to work with loaders:
	* - Collada
	* - gltf
	*/
    numAnimMeshes:      u32,

    /**
	* Attachment meshes for this mesh, for vertex-based animation.
	* Attachment meshes carry replacement data for some of the
	* mesh'es vertex components (usually positions, normals).
	* Currently known to work with loaders:
	* - Collada
	* - gltf
	*/
    animMeshes:         ^^Anim_Mesh,

    /**
	*  Method of morphing when anim-meshes are specified.
	*  @see aiMorphingMethod to learn more about the provided morphing targets.
	*/
    method:             Morphing_Method,

    /**
	*  The bounding box.
	*/
    aabb:               AABB,

    /**
	* Vertex UV stream names. Pointer to array of size AI_MAX_NUMBER_OF_TEXTURECOORDS
	*/
    textureCoordsNames: ^^String,
}

/**
* @brief  A skeleton bone represents a single bone is a skeleton structure.
*
* Skeleton-Animations can be represented via a skeleton struct, which describes
* a hierarchical tree assembled from skeleton bones. A bone is linked to a mesh.
* The bone knows its parent bone. If there is no parent bone the parent id is
* marked with -1.
* The skeleton-bone stores a pointer to its used armature. If there is no
* armature this value if set to nullptr.
* A skeleton bone stores its offset-matrix, which is the absolute transformation
* for the bone. The bone stores the locale transformation to its parent as well.
* You can compute the offset matrix by multiplying the hierarchy like:
* Tree: s1 -> s2 -> s3
* Offset-Matrix s3 = locale-s3 * locale-s2 * locale-s1
*/
Skeleton_Bone :: struct {
    /// The parent bone index, is -1 one if this bone represents the root bone.
    parent:       i32,

    /// @brief The bone armature node - used for skeleton conversion
    /// you must enable aiProcess_PopulateArmatureData to populate this
    armature:     ^Node,

    /// @brief The bone node in the scene - used for skeleton conversion
    /// you must enable aiProcess_PopulateArmatureData to populate this
    node:         ^Node,

    /// @brief The number of weights
    numnWeights:  u32,

    /// The mesh index, which will get influenced by the weight.
    meshId:       ^Mesh,

    /// The influence weights of this bone, by vertex index.
    weights:      ^Vertex_Weight,

    /** Matrix that transforms from bone space to mesh space in bind pose.
	*
	* This matrix describes the position of the mesh
	* in the local space of this bone when the skeleton was bound.
	* Thus it can be used directly to determine a desired vertex position,
	* given the world-space transform of the bone when animated,
	* and the position of the vertex in mesh space.
	*
	* It is sometimes called an inverse-bind matrix,
	* or inverse bind pose matrix.
	*/
    offsetMatrix: Matrix4x4,

    /// Matrix that transforms the locale bone in bind pose.
    localMatrix:  Matrix4x4,
}

/**
* @brief A skeleton represents the bone hierarchy of an animation.
*
* Skeleton animations can be described as a tree of bones:
*                  root
*                    |
*                  node1
*                  /   \
*               node3  node4
* If you want to calculate the transformation of node three you need to compute the
* transformation hierarchy for the transformation chain of node3:
* root->node1->node3
* Each node is represented as a skeleton instance.
*/
Skeleton :: struct {
    /**
	*  @brief The name of the skeleton instance.
	*/
    name:     String,

    /**
	*  @brief  The number of bones in the skeleton.
	*/
    numBones: u32,

    /**
	*  @brief The bone instance in the skeleton.
	*/
    bones:    ^^Skeleton_Bone,
}

/** Enumerates all supported types of light sources.
*/
Light_Source_Type :: enum c.int {
    UNDEFINED   = 0,

    //! A directional light source has a well-defined direction
    //! but is infinitely far away. That's quite a good
    //! approximation for sun light.
    DIRECTIONAL = 1,

    //! A point light source has a well-defined position
    //! in space but no direction - it emits light in all
    //! directions. A normal bulb is a point light.
    POINT       = 2,

    //! A spot light source emits light in a specific
    //! angle. It has a position and a direction it is pointing to.
    //! A good example for a spot light is a light spot in
    //! sport arenas.
    SPOT        = 3,

    //! The generic light level of the world, including the bounces
    //! of all other light sources.
    //! Typically, there's at most one ambient light in a scene.
    //! This light type doesn't have a valid position, direction, or
    //! other properties, just a color.
    AMBIENT     = 4,

    //! An area light is a rectangle with predefined size that uniformly
    //! emits light from one of its sides. The position is center of the
    //! rectangle and direction is its normal vector.
    AREA        = 5,
}

/** Helper structure to describe a light source.
*
*  Assimp supports multiple sorts of light sources, including
*  directional, point and spot lights. All of them are defined with just
*  a single structure and distinguished by their parameters.
*  Note - some file formats (such as 3DS, ASE) export a "target point" -
*  the point a spot light is looking at (it can even be animated). Assimp
*  writes the target point as a sub-node of a spot-lights's main node,
*  called "<spotName>.Target". However, this is just additional information
*  then, the transformation tracks of the main node make the
*  spot light already point in the right direction.
*/
Light :: struct {
    /** The name of the light source.
	*
	*  There must be a node in the scene-graph with the same name.
	*  This node specifies the position of the light in the scene
	*  hierarchy and can be animated.
	*/
    name:                 String,

    /** The type of the light source.
	*
	* aiLightSource_UNDEFINED is not a valid value for this member.
	*/
    type:                 Light_Source_Type,

    /** Position of the light source in space. Relative to the
	*  transformation of the node corresponding to the light.
	*
	*  The position is undefined for directional lights.
	*/
    position:             Vector3d,

    /** Direction of the light source in space. Relative to the
	*  transformation of the node corresponding to the light.
	*
	*  The direction is undefined for point lights. The vector
	*  may be normalized, but it needn't.
	*/
    direction:            Vector3d,

    /** Up direction of the light source in space. Relative to the
	*  transformation of the node corresponding to the light.
	*
	*  The direction is undefined for point lights. The vector
	*  may be normalized, but it needn't.
	*/
    up:                   Vector3d,

    /** Constant light attenuation factor.
	*
	*  The intensity of the light source at a given distance 'd' from
	*  the light's position is
	*  @code
	*  Atten = 1/( att0 + att1 * d + att2 * d*d)
	*  @endcode
	*  This member corresponds to the att0 variable in the equation.
	*  Naturally undefined for directional lights.
	*/
    attenuationConstant:  f32,

    /** Linear light attenuation factor.
	*
	*  The intensity of the light source at a given distance 'd' from
	*  the light's position is
	*  @code
	*  Atten = 1/( att0 + att1 * d + att2 * d*d)
	*  @endcode
	*  This member corresponds to the att1 variable in the equation.
	*  Naturally undefined for directional lights.
	*/
    attenuationLinear:    f32,

    /** Quadratic light attenuation factor.
	*
	*  The intensity of the light source at a given distance 'd' from
	*  the light's position is
	*  @code
	*  Atten = 1/( att0 + att1 * d + att2 * d*d)
	*  @endcode
	*  This member corresponds to the att2 variable in the equation.
	*  Naturally undefined for directional lights.
	*/
    attenuationQuadratic: f32,

    /** Diffuse color of the light source
	*
	*  The diffuse light color is multiplied with the diffuse
	*  material color to obtain the final color that contributes
	*  to the diffuse shading term.
	*/
    colorDiffuse:         Color3d,

    /** Specular color of the light source
	*
	*  The specular light color is multiplied with the specular
	*  material color to obtain the final color that contributes
	*  to the specular shading term.
	*/
    colorSpecular:        Color3d,

    /** Ambient color of the light source
	*
	*  The ambient light color is multiplied with the ambient
	*  material color to obtain the final color that contributes
	*  to the ambient shading term. Most renderers will ignore
	*  this value it, is just a remaining of the fixed-function pipeline
	*  that is still supported by quite many file formats.
	*/
    colorAmbient:         Color3d,

    /** Inner angle of a spot light's light cone.
	*
	*  The spot light has maximum influence on objects inside this
	*  angle. The angle is given in radians. It is 2PI for point
	*  lights and undefined for directional lights.
	*/
    angleInnerCone:       f32,

    /** Outer angle of a spot light's light cone.
	*
	*  The spot light does not affect objects outside this angle.
	*  The angle is given in radians. It is 2PI for point lights and
	*  undefined for directional lights. The outer angle must be
	*  greater than or equal to the inner angle.
	*  It is assumed that the application uses a smooth
	*  interpolation between the inner and the outer cone of the
	*  spot light.
	*/
    angleOuterCone:       f32,

    /** Size of area light source. */
    size:                 Vector2d,
}


/** Helper structure to describe a virtual camera.
*
* Cameras have a representation in the node graph and can be animated.
* An important aspect is that the camera itself is also part of the
* scene-graph. This means, any values such as the look-at vector are not
* *absolute*, they're <b>relative</b> to the coordinate system defined
* by the node which corresponds to the camera. This allows for camera
* animations. For static cameras parameters like the 'look-at' or 'up' vectors
* are usually specified directly in aiCamera, but beware, they could also
* be encoded in the node transformation. The following (pseudo)code sample
* shows how to do it: <br><br>
* @code
* // Get the camera matrix for a camera at a specific time
* // if the node hierarchy for the camera does not contain
* // at least one animated node this is a static computation
* get-camera-matrix (node sceneRoot, camera cam) : matrix
* {
*    node   cnd = find-node-for-camera(cam)
*    matrix cmt = identity()
*
*    // as usual - get the absolute camera transformation for this frame
*    for each node nd in hierarchy from sceneRoot to cnd
*      matrix cur
*      if (is-animated(nd))
*         cur = eval-animation(nd)
*      else cur = nd->mTransformation;
*      cmt = mult-matrices( cmt, cur )
*    end for
*
*    // now multiply with the camera's own local transform
*    cam = mult-matrices (cam, get-camera-matrix(cmt) )
* }
* @endcode
*
* @note some file formats (such as 3DS, ASE) export a "target point" -
* the point the camera is looking at (it can even be animated). Assimp
* writes the target point as a subnode of the camera's main node,
* called "<camName>.Target". However this is just additional information
* then the transformation tracks of the camera main node make the
* camera already look in the right direction.
*
*/
Camera :: struct {
    /** The name of the camera.
	*
	*  There must be a node in the scenegraph with the same name.
	*  This node specifies the position of the camera in the scene
	*  hierarchy and can be animated.
	*/
    name:              String,

    /** Position of the camera relative to the coordinate space
	*  defined by the corresponding node.
	*
	*  The default value is 0|0|0.
	*/
    position:          Vector3d,

    /** 'Up' - vector of the camera coordinate system relative to
	*  the coordinate space defined by the corresponding node.
	*
	*  The 'right' vector of the camera coordinate system is
	*  the cross product of  the up and lookAt vectors.
	*  The default value is 0|1|0. The vector
	*  may be normalized, but it needn't.
	*/
    up:                Vector3d,

    /** 'LookAt' - vector of the camera coordinate system relative to
	*  the coordinate space defined by the corresponding node.
	*
	*  This is the viewing direction of the user.
	*  The default value is 0|0|1. The vector
	*  may be normalized, but it needn't.
	*/
    lookAt:            Vector3d,

    /** Horizontal field of view angle, in radians.
	*
	*  The field of view angle is the angle between the center
	*  line of the screen and the left or right border.
	*  The default value is 1/4PI.
	*/
    horizontalFOV:     f32,

    /** Distance of the near clipping plane from the camera.
	*
	* The value may not be 0.f (for arithmetic reasons to prevent
	* a division through zero). The default value is 0.1f.
	*/
    clipPlaneNear:     f32,

    /** Distance of the far clipping plane from the camera.
	*
	* The far clipping plane must, of course, be further away than the
	* near clipping plane. The default value is 1000.f. The ratio
	* between the near and the far plane should not be too
	* large (between 1000-10000 should be ok) to avoid floating-point
	* inaccuracies which could lead to z-fighting.
	*/
    clipPlaneFar:      f32,

    /** Screen aspect ratio.
	*
	* This is the ration between the width and the height of the
	* screen. Typical values are 4/3, 1/2 or 1/1. This value is
	* 0 if the aspect ratio is not defined in the source file.
	* 0 is also the default value.
	*/
    aspect:            f32,

    /** Half horizontal orthographic width, in scene units.
	*
	*  The orthographic width specifies the half width of the
	*  orthographic view box. If non-zero the camera is
	*  orthographic and the mAspect should define to the
	*  ratio between the orthographic width and height
	*  and mHorizontalFOV should be set to 0.
	*  The default value is 0 (not orthographic).
	*/
    orthographicWidth: f32,
}

REAL_TEXT_PRECISION :: 9

Anim_Interpolation :: enum c.int {
    Step,
    Linear,
    Spherical_Linear,
    Cubic_Spline,
}

/** A time-value pair specifying a certain 3D vector for the given time. */
Vector_Key :: struct {
    /** The time of this key */
    time:          f64,

    /** The value of this key */
    value:         Vector3d,

    /** The interpolation setting of this key */
    interpolation: Anim_Interpolation,
}

/** A time-value pair specifying a rotation for the given time.
*  Rotations are expressed with quaternions. */
Quat_Key :: struct {
    /** The time of this key */
    time:          f64,

    /** The value of this key */
    value:         Quaternion,

    /** The interpolation setting of this key */
    interpolation: Anim_Interpolation,
}

/** Binds a anim-mesh to a specific point in time. */
Mesh_Key :: struct {
    /** The time of this key */
    time:  f64,

    /** Index into the aiMesh::mAnimMeshes array of the
	*  mesh corresponding to the #aiMeshAnim hosting this
	*  key frame. The referenced anim mesh is evaluated
	*  according to the rules defined in the docs for #aiAnimMesh.*/
    value: u32,
}

/** Binds a morph anim mesh to a specific point in time. */
Mesh_Morph_Key :: struct {
    /** The time of this key */
    time:                f64,

    /** The values and weights at the time of this key
	*   - mValues: index of attachment mesh to apply weight at the same position in mWeights
	*   - mWeights: weight to apply to the blend shape index at the same position in mValues
	*/
    values:              ^u32,
    weights:             ^f64,

    /** The number of values and weights */
    numValuesAndWeights: u32,
}

/** Defines how an animation channel behaves outside the defined time
*  range. This corresponds to aiNodeAnim::mPreState and
*  aiNodeAnim::mPostState.*/
Anim_Behaviour :: enum c.int {
    /** The value from the default node transformation is taken*/
    DEFAULT  = 0,

    /** The nearest key value is used without interpolation */
    CONSTANT = 1,

    /** The value of the nearest two keys is linearly
	*  extrapolated for the current time value.*/
    LINEAR   = 2,

    /** The animation is repeated.
	*
	*  If the animation key go from n to m and the current
	*  time is t, use the value at (t-n) % (|m-n|).*/
    REPEAT   = 3,
}

/** Describes the animation of a single node. The name specifies the
*  bone/node which is affected by this animation channel. The keyframes
*  are given in three separate series of values, one each for position,
*  rotation and scaling. The transformation matrix computed from these
*  values replaces the node's original transformation matrix at a
*  specific time.
*  This means all keys are absolute and not relative to the bone default pose.
*  The order in which the transformations are applied is
*  - as usual - scaling, rotation, translation.
*
*  @note All keys are returned in their correct, chronological order.
*  Duplicate keys don't pass the validation step. Most likely there
*  will be no negative time values, but they are not forbidden also ( so
*  implementations need to cope with them! ) */
Node_Anim :: struct {
    /** The name of the node affected by this animation. The node
	*  must exist and it must be unique.*/
    nodeName:        String,

    /** The number of position keys */
    numPositionKeys: u32,

    /** The position keys of this animation channel. Positions are
	* specified as 3D vector. The array is mNumPositionKeys in size.
	*
	* If there are position keys, there will also be at least one
	* scaling and one rotation key.*/
    positionKeys:    ^Vector_Key,

    /** The number of rotation keys */
    numRotationKeys: u32,

    /** The rotation keys of this animation channel. Rotations are
	*  given as quaternions,  which are 4D vectors. The array is
	*  mNumRotationKeys in size.
	*
	* If there are rotation keys, there will also be at least one
	* scaling and one position key. */
    rotationKeys:    ^Quat_Key,

    /** The number of scaling keys */
    numScalingKeys:  u32,

    /** The scaling keys of this animation channel. Scalings are
	*  specified as 3D vector. The array is mNumScalingKeys in size.
	*
	* If there are scaling keys, there will also be at least one
	* position and one rotation key.*/
    scalingKeys:     ^Vector_Key,

    /** Defines how the animation behaves before the first
	*  key is encountered.
	*
	*  The default value is aiAnimBehaviour_DEFAULT (the original
	*  transformation matrix of the affected node is used).*/
    preState:        Anim_Behaviour,

    /** Defines how the animation behaves after the last
	*  key was processed.
	*
	*  The default value is aiAnimBehaviour_DEFAULT (the original
	*  transformation matrix of the affected node is taken).*/
    postState:       Anim_Behaviour,
}

// ---------------------------------------------------------------------------
/** Describes vertex-based animations for a single mesh or a group of
*  meshes. Meshes carry the animation data for each frame in their
*  aiMesh::mAnimMeshes array. The purpose of aiMeshAnim is to
*  define keyframes linking each mesh attachment to a particular
*  point in time. */
Mesh_Anim :: struct {
    /** Name of the mesh to be animated. An empty string is not allowed,
	*  animated meshes need to be named (not necessarily uniquely,
	*  the name can basically serve as wild-card to select a group
	*  of meshes with similar animation setup)*/
    name:    String,

    /** Size of the #mKeys array. Must be 1, at least. */
    numKeys: u32,

    /** Key frames of the animation. May not be nullptr. */
    keys:    ^Mesh_Key,
}

// ---------------------------------------------------------------------------
/** Describes a morphing animation of a given mesh. */
Mesh_Morph_Anim :: struct {
    /** Name of the mesh to be animated. An empty string is not allowed,
	*  animated meshes need to be named (not necessarily uniquely,
	*  the name can basically serve as wildcard to select a group
	*  of meshes with similar animation setup)*/
    name:    String,

    /** Size of the #mKeys array. Must be 1, at least. */
    numKeys: u32,

    /** Key frames of the animation. May not be nullptr. */
    keys:    ^Mesh_Morph_Key,
}

// ---------------------------------------------------------------------------
/** An animation consists of key-frame data for a number of nodes. For
*  each node affected by the animation a separate series of data is given.*/
Animation :: struct {
    /** The name of the animation. If the modeling package this data was
	*  exported from does support only a single animation channel, this
	*  name is usually empty (length is zero). */
    name:                 String,

    /** Duration of the animation in ticks.  */
    duration:             f64,

    /** Ticks per second. 0 if not specified in the imported file */
    ticksPerSecond:       f64,

    /** The number of bone animation channels. Each channel affects
	*  a single node. */
    numChannels:          u32,

    /** The node animation channels. Each channel affects a single node.
	*  The array is mNumChannels in size. */
    channels:             ^^Node_Anim,

    /** The number of mesh animation channels. Each channel affects
	*  a single mesh and defines vertex-based animation. */
    numMeshChannels:      u32,

    /** The mesh animation channels. Each channel affects a single mesh.
	*  The array is mNumMeshChannels in size. */
    meshChannels:         ^^Mesh_Anim,

    /** The number of mesh animation channels. Each channel affects
	*  a single mesh and defines morphing animation. */
    numMorphMeshChannels: u32,

    /** The morph mesh animation channels. Each channel affects a single mesh.
	*  The array is mNumMorphMeshChannels in size. */
    morphMeshChannels:    ^^Mesh_Morph_Anim,
}
