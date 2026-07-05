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


/** Mixed set of flags for #aiImporterDesc, indicating some features
*  common to many importers*/
Importer_Flags :: enum c.int {
    /** Indicates that there is a textual encoding of the
	*  file format; and that it is supported.*/
    SupportTextFlavour       = 1,

    /** Indicates that there is a binary encoding of the
	*  file format; and that it is supported.*/
    SupportBinaryFlavour     = 2,

    /** Indicates that there is a compressed encoding of the
	*  file format; and that it is supported.*/
    SupportCompressedFlavour = 4,

    /** Indicates that the importer reads only a very particular
	* subset of the file format. This happens commonly for
	* declarative or procedural formats which cannot easily
	* be mapped to #aiScene */
    LimitedSupport           = 8,

    /** Indicates that the importer is highly experimental and
	* should be used with care. This only happens for trunk
	* (i.e. SVN) versions, experimental code is not included
	* in releases. */
    Experimental             = 16,
}

/** Meta information about a particular importer. Importers need to fill
*  this structure, but they can freely decide how talkative they are.
*  A common use case for loader meta info is a user interface
*  in which the user can choose between various import/export file
*  formats. Building such an UI by hand means a lot of maintenance
*  as importers/exporters are added to Assimp, so it might be useful
*  to have a common mechanism to query some rough importer
*  characteristics. */
Importer_Desc :: struct {
    /** Full name of the importer (i.e. Blender3D importer)*/
    name:           cstring,

    /** Original author (left blank if unknown or whole assimp team) */
    author:         cstring,

    /** Current maintainer, left blank if the author maintains */
    maintainer:     cstring,

    /** Implementation comments, i.e. unimplemented features*/
    comments:       cstring,

    /** These flags indicate some characteristics common to many
	importers. */
    flags:          u32,

    /** Minimum format version that can be loaded im major.minor format,
	both are set to 0 if there is either no version scheme
	or if the loader doesn't care. */
    minMajor:       u32,
    minMinor:       u32,

    /** Maximum format version that can be loaded im major.minor format,
	both are set to 0 if there is either no version scheme
	or if the loader doesn't care. Loaders that expect to be
	forward-compatible to potential future format versions should
	indicate  zero, otherwise they should specify the current
	maximum version.*/
    maxMajor:       u32,
    maxMinor:       u32,

    /** List of file extensions this importer can handle.
	List entries are separated by space characters.
	All entries are lower case without a leading dot (i.e.
	"xml dae" would be a valid value. Note that multiple
	importers may respond to the same file extension -
	assimp calls all importers in the order in which they
	are registered and each importer gets the opportunity
	to load the file until one importer "claims" the file. Apart
	from file extension checks, importers typically use
	other methods to quickly reject files (i.e. magic
	words) so this does not mean that common or generic
	file extensions such as XML would be tediously slow. */
    fileExtensions: cstring,
}

@(default_calling_convention = "c", link_prefix = "ai")
foreign lib {
    /** \brief  Returns the Importer description for a given extension.
	
	Will return a nullptr if no assigned importer desc. was found for the given extension
	\param  extension   [in] The extension to look for
	\return A pointer showing to the ImporterDesc, \see aiImporterDesc.
	*/
    GetImporterDesc :: proc(extension: cstring) -> ^Importer_Desc ---
}
