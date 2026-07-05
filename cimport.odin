package assimp

import "core:c"

_ :: c

when ODIN_OS == .Windows {
    when ODIN_ARCH == .amd64 {
        foreign import lib {"vendor:zlib/libz.lib", "windows_x64/libassimp.lib"}
    } else when ODIN_ARCH == .arm64 {
        foreign import lib {"vendor:zlib/libz.lib", "windows_arm64/libassimp.lib"}
    } else {
        #panic("vendor/assimp supports windows amd64/arm64 only")
    }
} else when ODIN_OS == .Darwin {
    when ODIN_ARCH == .amd64 {
        foreign import lib {"vendor:zlib/libz.lib", "darwin_x64/libassimp.darwin.a"}
    } else when ODIN_ARCH == .arm64 {
        foreign import lib {"vendor:zlib/libz.lib", "darwin_arm64/libassimp.darwin.a"}
    } else {
        #panic("vendor/assimp supports Darwin amd64/arm64 only")
    }
} else when ODIN_OS == .Linux {
    when ODIN_ARCH == .amd64 {
        foreign import lib {"system:z", "linux_x64/libassimp.linux.a"}
    } else when ODIN_ARCH == .arm64 {
        foreign import lib {"system:z", "linux_arm64/libassimp.linux.a"}
    } else {
        #panic("vendor/assimp supports linux amd64/arm64 only")
    }
}


Log_Stream_Callback :: proc "c" (_: cstring, _: cstring)

/** C-API: Represents a log stream. A log stream receives all log messages and
*  streams them _somewhere_.
*  @see aiGetPredefinedLogStream
*  @see aiAttachLogStream
*  @see aiDetachLogStream */
Log_Stream :: struct {
    /** callback to be called */
    callback: Log_Stream_Callback,

    /** user data to be passed to the callback */
    user:     cstring,
}

/** C-API: Represents an opaque set of settings to be used during importing.
*  @see aiCreatePropertyStore
*  @see aiReleasePropertyStore
*  @see aiImportFileExWithProperties
*  @see aiSetPropertyInteger
*  @see aiSetPropertyFloat
*  @see aiSetPropertyString
*  @see aiSetPropertyMatrix
*/
Property_Store :: struct {
    sentinel: u8,
}

/** Our own C boolean type */
Bool :: i32

FALSE :: 0
TRUE :: 1

@(default_calling_convention = "c", link_prefix = "ai")
foreign lib {
    /** Reads the given file and returns its content.
	*
	* If the call succeeds, the imported data is returned in an aiScene structure.
	* The data is intended to be read-only, it stays property of the ASSIMP
	* library and will be stable until aiReleaseImport() is called. After you're
	* done with it, call aiReleaseImport() to free the resources associated with
	* this file. If the import fails, NULL is returned instead. Call
	* aiGetErrorString() to retrieve a human-readable error text.
	* @param pFile Path and filename of the file to be imported,
	*   expected to be a null-terminated c-string. NULL is not a valid value.
	* @param pFlags Optional post processing steps to be executed after
	*   a successful import. Provide a bitwise combination of the
	*   #aiPostProcessSteps flags.
	* @return Pointer to the imported data or NULL if the import failed.
	*/
    ImportFile :: proc(pFile: cstring, pFlags: u32) -> ^Scene ---

    /** Reads the given file using user-defined I/O functions and returns
	*   its content.
	*
	* If the call succeeds, the imported data is returned in an aiScene structure.
	* The data is intended to be read-only, it stays property of the ASSIMP
	* library and will be stable until aiReleaseImport() is called. After you're
	* done with it, call aiReleaseImport() to free the resources associated with
	* this file. If the import fails, NULL is returned instead. Call
	* aiGetErrorString() to retrieve a human-readable error text.
	* @param pFile Path and filename of the file to be imported,
	*   expected to be a null-terminated c-string. NULL is not a valid value.
	* @param pFlags Optional post processing steps to be executed after
	*   a successful import. Provide a bitwise combination of the
	*   #aiPostProcessSteps flags.
	* @param pFS aiFileIO structure. Will be used to open the model file itself
	*   and any other files the loader needs to open.  Pass NULL to use the default
	*   implementation.
	* @return Pointer to the imported data or NULL if the import failed.
	* @note Include <aiFileIO.h> for the definition of #aiFileIO.
	*/
    ImportFileEx :: proc(pFile: cstring, pFlags: u32, pFS: ^File_IO) -> ^Scene ---

    /** Same as #aiImportFileEx, but adds an extra parameter containing importer settings.
	*
	* @param pFile Path and filename of the file to be imported,
	*   expected to be a null-terminated c-string. NULL is not a valid value.
	* @param pFlags Optional post processing steps to be executed after
	*   a successful import. Provide a bitwise combination of the
	*   #aiPostProcessSteps flags.
	* @param pFS aiFileIO structure. Will be used to open the model file itself
	*   and any other files the loader needs to open.  Pass NULL to use the default
	*   implementation.
	* @param pProps #aiPropertyStore instance containing import settings.
	* @return Pointer to the imported data or NULL if the import failed.
	* @note Include <aiFileIO.h> for the definition of #aiFileIO.
	* @see aiImportFileEx
	*/
    ImportFileExWithProperties :: proc(pFile: cstring, pFlags: u32, pFS: ^File_IO, pProps: ^Property_Store) -> ^Scene ---

    /** Reads the given file from a given memory buffer,
	*
	* If the call succeeds, the imported data is returned in an aiScene structure.
	* The data is intended to be read-only, it stays property of the ASSIMP
	* library and will be stable until aiReleaseImport() is called. After you're
	* done with it, call aiReleaseImport() to free the resources associated with
	* this file. If the import fails, NULL is returned.
	* A human-readable error description can be retrieved by calling aiGetErrorString().
	* @param pBuffer Pointer to the file data
	* @param pLength Length of pBuffer, in bytes
	* @param pFlags Optional post processing steps to be executed after
	*   a successful import. Provide a bitwise combination of the
	*   #aiPostProcessSteps flags. If you wish to inspect the imported
	*   scene first in order to fine-tune your post-processing setup,
	*   consider to use #aiApplyPostProcessing().
	* @param pHint An additional hint to the library. If this is a non empty string,
	*   the library looks for a loader to support the file extension specified by pHint
	*   and passes the file to the first matching loader. If this loader is unable to
	*   completely the request, the library continues and tries to determine the file
	*   format on its own, a task that may or may not be successful.
	*   Check the return value, and you'll know ...
	* @return A pointer to the imported data, NULL if the import failed.
	*
	* @note This is a straightforward way to decode models from memory
	* buffers, but it doesn't handle model formats that spread their
	* data across multiple files or even directories. Examples include
	* OBJ or MD3, which outsource parts of their material info into
	* external scripts. If you need full functionality, provide
	* a custom IOSystem to make Assimp find these files and use
	* the regular aiImportFileEx()/aiImportFileExWithProperties() API.
	*/
    ImportFileFromMemory :: proc(pBuffer: cstring, pLength: u32, pFlags: u32, pHint: cstring) -> ^Scene ---

    /** Same as #aiImportFileFromMemory, but adds an extra parameter containing importer settings.
	*
	* @param pBuffer Pointer to the file data
	* @param pLength Length of pBuffer, in bytes
	* @param pFlags Optional post processing steps to be executed after
	*   a successful import. Provide a bitwise combination of the
	*   #aiPostProcessSteps flags. If you wish to inspect the imported
	*   scene first in order to fine-tune your post-processing setup,
	*   consider to use #aiApplyPostProcessing().
	* @param pHint An additional hint to the library. If this is a non empty string,
	*   the library looks for a loader to support the file extension specified by pHint
	*   and passes the file to the first matching loader. If this loader is unable to
	*   completely the request, the library continues and tries to determine the file
	*   format on its own, a task that may or may not be successful.
	*   Check the return value, and you'll know ...
	* @param pProps #aiPropertyStore instance containing import settings.
	* @return A pointer to the imported data, NULL if the import failed.
	*
	* @note This is a straightforward way to decode models from memory
	* buffers, but it doesn't handle model formats that spread their
	* data across multiple files or even directories. Examples include
	* OBJ or MD3, which outsource parts of their material info into
	* external scripts. If you need full functionality, provide
	* a custom IOSystem to make Assimp find these files and use
	* the regular aiImportFileEx()/aiImportFileExWithProperties() API.
	* @see aiImportFileFromMemory
	*/
    ImportFileFromMemoryWithProperties :: proc(pBuffer: cstring, pLength: u32, pFlags: u32, pHint: cstring, pProps: ^Property_Store) -> ^Scene ---

    /** Apply post-processing to an already-imported scene.
	*
	* This is strictly equivalent to calling #aiImportFile()/#aiImportFileEx with the
	* same flags. However, you can use this separate function to inspect the imported
	* scene first to fine-tune your post-processing setup.
	* @param pScene Scene to work on.
	* @param pFlags Provide a bitwise combination of the #aiPostProcessSteps flags.
	* @return A pointer to the post-processed data. Post processing is done in-place,
	*   meaning this is still the same #aiScene which you passed for pScene. However,
	*   _if_ post-processing failed, the scene could now be NULL. That's quite a rare
	*   case, post processing steps are not really designed to 'fail'. To be exact,
	*   the #aiProcess_ValidateDataStructure flag is currently the only post processing step
	*   which can actually cause the scene to be reset to NULL.
	*/
    ApplyPostProcessing :: proc(pScene: ^Scene, pFlags: u32) -> ^Scene ---

    /** Get one of the predefine log streams. This is the quick'n'easy solution to
	*  access Assimp's log system. Attaching a log stream can slightly reduce Assimp's
	*  overall import performance.
	*
	*  Usage is rather simple (this will stream the log to a file, named log.txt, and
	*  the stdout stream of the process:
	*  @code
	*    struct aiLogStream c;
	*    c = aiGetPredefinedLogStream(aiDefaultLogStream_FILE,"log.txt");
	*    aiAttachLogStream(&c);
	*    c = aiGetPredefinedLogStream(aiDefaultLogStream_STDOUT,NULL);
	*    aiAttachLogStream(&c);
	*  @endcode
	*
	*  @param pStreams One of the #aiDefaultLogStream enumerated values.
	*  @param file Solely for the #aiDefaultLogStream_FILE flag: specifies the file to write to.
	*    Pass NULL for all other flags.
	*  @return The log stream. callback is set to NULL if something went wrong.
	*/
    GetPredefinedLogStream :: proc(pStreams: Default_Log_Stream, file: cstring) -> Log_Stream ---

    /** Attach a custom log stream to the libraries' logging system.
	*
	*  Attaching a log stream can slightly reduce Assimp's overall import
	*  performance. Multiple log-streams can be attached.
	*  @param stream Describes the new log stream.
	*  @note To ensure proper destruction of the logging system, you need to manually
	*    call aiDetachLogStream() on every single log stream you attach.
	*    Alternatively (for the lazy folks) #aiDetachAllLogStreams is provided.
	*/
    AttachLogStream :: proc(stream: ^Log_Stream) ---

    /** Enable verbose logging. Verbose logging includes debug-related stuff and
	*  detailed import statistics. This can have severe impact on import performance
	*  and memory consumption. However, it might be useful to find out why a file
	*  didn't read correctly.
	*  @param d AI_TRUE or AI_FALSE, your decision.
	*/
    EnableVerboseLogging :: proc(d: bool) ---

    /** Detach a custom log stream from the libraries' logging system.
	*
	*  This is the counterpart of #aiAttachLogStream. If you attached a stream,
	*  don't forget to detach it again.
	*  @param stream The log stream to be detached.
	*  @return AI_SUCCESS if the log stream has been detached successfully.
	*  @see aiDetachAllLogStreams
	*/
    DetachLogStream :: proc(stream: ^Log_Stream) -> Return ---

    /** Detach all active log streams from the libraries' logging system.
	*  This ensures that the logging system is terminated properly and all
	*  resources allocated by it are actually freed. If you attached a stream,
	*  don't forget to detach it again.
	*  @see aiAttachLogStream
	*  @see aiDetachLogStream
	*/
    DetachAllLogStreams :: proc() ---

    /** Releases all resources associated with the given import process.
	*
	* Call this function after you're done with the imported data.
	* @param pScene The imported data to release. NULL is a valid value.
	*/
    ReleaseImport :: proc(pScene: ^Scene) ---

    /** Returns the error text of the last failed import process.
	*
	* @return A textual description of the error that occurred at the last
	* import process. NULL if there was no error. There can't be an error if you
	* got a non-NULL #aiScene from #aiImportFile/#aiImportFileEx/#aiApplyPostProcessing.
	*/
    GetErrorString :: proc() -> cstring ---

    /** Returns whether a given file extension is supported by ASSIMP
	*
	* @param szExtension Extension for which the function queries support for.
	* Must include a leading dot '.'. Example: ".3ds", ".md3"
	* @return AI_TRUE if the file extension is supported.
	*/
    IsExtensionSupported :: proc(szExtension: cstring) -> bool ---

    /** Get a list of all file extensions supported by ASSIMP.
	*
	* If a file extension is contained in the list this does, of course, not
	* mean that ASSIMP is able to load all files with this extension.
	* @param szOut String to receive the extension list.
	* Format of the list: "*.3ds;*.obj;*.dae". NULL is not a valid parameter.
	*/
    GetExtensionList :: proc(szOut: ^String) ---

    /** Get the approximated storage required by an imported asset
	* @param pIn Input asset.
	* @param in Data structure to be filled.
	*/
    GetMemoryRequirements :: proc(pIn: ^Scene, _in: ^Memory_Info) ---

    /** Returns an embedded texture, or nullptr.
	* @param pIn Input asset.
	* @param filename Texture path extracted from aiGetMaterialString.
	*/
    GetEmbeddedTexture :: proc(pIn: ^Scene, filename: cstring) -> ^Texture ---

    /** Create an empty property store. Property stores are used to collect import
	*  settings.
	* @return New property store. Property stores need to be manually destroyed using
	*   the #aiReleasePropertyStore API function.
	*/
    CreatePropertyStore :: proc() -> ^Property_Store ---

    /** Delete a property store.
	* @param p Property store to be deleted.
	*/
    ReleasePropertyStore :: proc(p: ^Property_Store) ---

    /** Set an integer property.
	*
	*  This is the C-version of #Assimp::Importer::SetPropertyInteger(). In the C
	*  interface, properties are always shared by all imports. It is not possible to
	*  specify them per import.
	*
	* @param store Store to modify. Use #aiCreatePropertyStore to obtain a store.
	* @param szName Name of the configuration property to be set. All supported
	*   public properties are defined in the config.h header file (AI_CONFIG_XXX).
	* @param value New value for the property
	*/
    SetImportPropertyInteger :: proc(store: ^Property_Store, szName: cstring, value: i32) ---

    /** Set a floating-point property.
	*
	*  This is the C-version of #Assimp::Importer::SetPropertyFloat(). In the C
	*  interface, properties are always shared by all imports. It is not possible to
	*  specify them per import.
	*
	* @param store Store to modify. Use #aiCreatePropertyStore to obtain a store.
	* @param szName Name of the configuration property to be set. All supported
	*   public properties are defined in the config.h header file (AI_CONFIG_XXX).
	* @param value New value for the property
	*/
    SetImportPropertyFloat :: proc(store: ^Property_Store, szName: cstring, value: f32) ---

    /** Set a string property.
	*
	*  This is the C-version of #Assimp::Importer::SetPropertyString(). In the C
	*  interface, properties are always shared by all imports. It is not possible to
	*  specify them per import.
	*
	* @param store Store to modify. Use #aiCreatePropertyStore to obtain a store.
	* @param szName Name of the configuration property to be set. All supported
	*   public properties are defined in the config.h header file (AI_CONFIG_XXX).
	* @param st New value for the property
	*/
    SetImportPropertyString :: proc(store: ^Property_Store, szName: cstring, st: ^String) ---

    /** Set a matrix property.
	*
	*  This is the C-version of #Assimp::Importer::SetPropertyMatrix(). In the C
	*  interface, properties are always shared by all imports. It is not possible to
	*  specify them per import.
	*
	* @param store Store to modify. Use #aiCreatePropertyStore to obtain a store.
	* @param szName Name of the configuration property to be set. All supported
	*   public properties are defined in the config.h header file (AI_CONFIG_XXX).
	* @param mat New value for the property
	*/
    SetImportPropertyMatrix :: proc(store: ^Property_Store, szName: cstring, mat: ^Matrix4x4) ---

    /** Construct a quaternion from a 3x3 rotation matrix.
	*  @param quat Receives the output quaternion.
	*  @param mat Matrix to 'quaternionize'.
	*  @see aiQuaternion(const aiMatrix3x3& pRotMatrix)
	*/
    CreateQuaternionFromMatrix :: proc(quat: ^Quaternion, mat: ^Matrix3x3) ---

    /** Decompose a transformation matrix into its rotational, translational and
	*  scaling components.
	*
	* @param mat Matrix to decompose
	* @param scaling Receives the scaling component
	* @param rotation Receives the rotational component
	* @param position Receives the translational component.
	* @see aiMatrix4x4::Decompose (aiVector3D&, aiQuaternion&, aiVector3D&) const;
	*/
    DecomposeMatrix :: proc(mat: ^Matrix4x4, scaling: ^Vector3d, rotation: ^Quaternion, position: ^Vector3d) ---

    /** Returns the number of import file formats available in the current Assimp build.
	* Use aiGetImportFormatDescription() to retrieve infos of a specific import format.
	*/
    GetImportFormatCount :: proc() -> uint ---

    /** Returns a description of the nth import file format. Use #aiGetImportFormatCount()
	* to learn how many import formats are supported.
	* @param pIndex Index of the import format to retrieve information for. Valid range is
	*    0 to #aiGetImportFormatCount()
	* @return A description of that specific import format. NULL if pIndex is out of range.
	*/
    GetImportFormatDescription :: proc(pIndex: uint) -> ^Importer_Desc ---

    /** Decompose a transformation matrix into its scaling,
	*  rotational as euler angles, and translational components.
	*
	* @param mat Matrix to decompose
	* @param scaling Receives the output scaling for the x,y,z axes
	* @param rotation Receives the output rotation as a Euler angles
	* @param position Receives the output position for the x,y,z axes
	*/
    Matrix4DecomposeIntoScalingEulerAnglesPosition :: proc(mat: ^Matrix4x4, scaling: ^Vector3d, rotation: ^Vector3d, position: ^Vector3d) ---

    /** Decompose a transformation matrix into its scaling,
	*  rotational split into an axis and rotational angle,
	*  and it's translational components.
	*
	* @param mat Matrix to decompose
	* @param rotation Receives the rotational component
	* @param axis Receives the output rotation axis
	* @param angle Receives the output rotation angle
	* @param position Receives the output position for the x,y,z axes.
	*/
    Matrix4DecomposeIntoScalingAxisAnglePosition :: proc(mat: ^Matrix4x4, scaling: ^Vector3d, axis: ^Vector3d, angle: ^f32, position: ^Vector3d) ---

    /** Decompose a transformation matrix into its rotational and
	*  translational components.
	*
	* @param mat Matrix to decompose
	* @param rotation Receives the rotational component
	* @param position Receives the translational component.
	*/
    Matrix4DecomposeNoScaling :: proc(mat: ^Matrix4x4, rotation: ^Quaternion, position: ^Vector3d) ---
}
