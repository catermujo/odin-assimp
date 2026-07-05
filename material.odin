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


@(default_calling_convention = "c", link_prefix = "ai")
foreign lib {
    /**
	* @brief  Get a string for a given aiTextureType
	*
	* @param  in  The texture type
	* @return The description string for the texture type.
	*/
    TextureTypeToString :: proc(_in: Texture_Type) -> cstring ---

    //! @endcond
    //!
    /** @brief Retrieve a material property with a specific key from the material
	*
	* @param pMat Pointer to the input material. May not be NULL
	* @param pKey Key to search for. One of the AI_MATKEY_XXX constants.
	* @param type Specifies the type of the texture to be retrieved (
	*    e.g. diffuse, specular, height map ...)
	* @param index Index of the texture to be retrieved.
	* @param pPropOut Pointer to receive a pointer to a valid aiMaterialProperty
	*        structure or NULL if the key has not been found. */
    GetMaterialProperty :: proc(pMat: ^Material, pKey: cstring, type: u32, index: u32, pPropOut: ^^Material_Property) -> Return ---

    /** @brief Retrieve an array of float values with a specific key
	*  from the material
	*
	* Pass one of the AI_MATKEY_XXX constants for the last three parameters (the
	* example reads the #AI_MATKEY_UVTRANSFORM property of the first diffuse texture)
	* @code
	* aiUVTransform trafo;
	* unsigned int max = sizeof(aiUVTransform);
	* if (AI_SUCCESS != aiGetMaterialFloatArray(mat, AI_MATKEY_UVTRANSFORM(aiTextureType_DIFFUSE,0),
	*    (float*)&trafo, &max) || sizeof(aiUVTransform) != max)
	* {
	*   // error handling
	* }
	* @endcode
	*
	* @param pMat Pointer to the input material. May not be NULL
	* @param pKey Key to search for. One of the AI_MATKEY_XXX constants.
	* @param pOut Pointer to a buffer to receive the result.
	* @param pMax Specifies the size of the given buffer, in float's.
	*        Receives the number of values (not bytes!) read.
	* @param type (see the code sample above)
	* @param index (see the code sample above)
	* @return Specifies whether the key has been found. If not, the output
	*   arrays remains unmodified and pMax is set to 0.*/
    GetMaterialFloatArray :: proc(pMat: ^Material, pKey: cstring, type: u32, index: u32, pOut: ^f32, pMax: ^u32) -> Return ---

    /** @brief Retrieve a single float property with a specific key from the material.
	*
	* Pass one of the AI_MATKEY_XXX constants for the last three parameters (the
	* example reads the #AI_MATKEY_SHININESS_STRENGTH property of the first diffuse texture)
	* @code
	* float specStrength = 1.f; // default value, remains unmodified if we fail.
	* aiGetMaterialFloat(mat, AI_MATKEY_SHININESS_STRENGTH,
	*    (float*)&specStrength);
	* @endcode
	*
	* @param pMat Pointer to the input material. May not be NULL
	* @param pKey Key to search for. One of the AI_MATKEY_XXX constants.
	* @param pOut Receives the output float.
	* @param type (see the code sample above)
	* @param index (see the code sample above)
	* @return Specifies whether the key has been found. If not, the output
	*   float remains unmodified.*/
    GetMaterialFloat :: proc(pMat: ^Material, pKey: cstring, type: u32, index: u32, pOut: ^f32) -> Return ---

    /** @brief Retrieve an array of integer values with a specific key
	*  from a material
	*
	* See the sample for aiGetMaterialFloatArray for more information.*/
    GetMaterialIntegerArray :: proc(pMat: ^Material, pKey: cstring, type: u32, index: u32, pOut: ^i32, pMax: ^u32) -> Return ---

    /** @brief Retrieve an integer property with a specific key from a material
	*
	* See the sample for aiGetMaterialFloat for more information.*/
    GetMaterialInteger :: proc(pMat: ^Material, pKey: cstring, type: u32, index: u32, pOut: ^i32) -> Return ---

    /** @brief Retrieve a color value from the material property table
	*
	* See the sample for aiGetMaterialFloat for more information*/
    GetMaterialColor :: proc(pMat: ^Material, pKey: cstring, type: u32, index: u32, pOut: ^Color4d) -> Return ---

    /** @brief Retrieve a aiUVTransform value from the material property table
	*
	* See the sample for aiGetMaterialFloat for more information*/
    GetMaterialUVTransform :: proc(pMat: ^Material, pKey: cstring, type: u32, index: u32, pOut: ^Uvtransform) -> Return ---

    /** @brief Retrieve a string from the material property table
	*
	* See the sample for aiGetMaterialFloat for more information.*/
    GetMaterialString :: proc(pMat: ^Material, pKey: cstring, type: u32, index: u32, pOut: ^String) -> Return ---

    /** Get the number of textures for a particular texture type.
	*  @param[in] pMat Pointer to the input material. May not be NULL
	*  @param type Texture type to check for
	*  @return Number of textures for this type.
	*  @note A texture can be easily queried using #aiGetMaterialTexture() */
    GetMaterialTextureCount :: proc(pMat: ^Material, type: Texture_Type) -> u32 ---
    GetMaterialTexture :: proc(mat: ^Material, type: Texture_Type, index: u32, path: ^String, mapping: ^Texture_Mapping, uvindex: ^u32, blend: ^f32, op: ^Texture_Op, mapmode: ^Texture_Map_Mode, flags: ^u32) -> Return ---
}
