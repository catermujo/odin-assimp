package assimp

import "core:c"

_ :: c

when ODIN_OS == .Windows {
    foreign import lib {"vendor:zlib/libz.lib", "libassimp.lib"}
} else when ODIN_OS == .Darwin {
    foreign import lib {"vendor:zlib/libz.lib", "libassimp.darwin.a"}
} else {
    foreign import lib {"system:z", "libassimp.linux.a"}
}


// aiFile callbacks
File_Write_Proc :: proc "c" (_: ^File, _: cstring, _: uint, _: uint) -> uint

File_Read_Proc :: proc "c" (_: ^File, _: cstring, _: uint, _: uint) -> uint

File_Tell_Proc :: proc "c" (_: ^File) -> uint

File_Flush_Proc :: proc "c" (_: ^File)

File_Seek :: proc "c" (_: ^File, _: uint, _: Origin) -> Return

// aiFileIO callbacks
File_Open_Proc :: struct {
}

File_Close_Proc :: proc "c" (_: ^File_IO, _: ^File)

// Represents user-defined data
User_Data :: cstring

/** @brief C-API: File system callbacks
*
*  Provided are functions to open and close files. Supply a custom structure to
*  the import function. If you don't, a default implementation is used. Use custom
*  file systems to enable reading from other sources, such as ZIPs
*  or memory locations. */
File_IO :: struct {
    /** Function used to open a new file
	*/
    OpenProc:  File_Open_Proc,

    /** Function used to close an existing file
	*/
    CloseProc: File_Close_Proc,

    /** User-defined, opaque data */
    UserData:  User_Data,
}

/** @brief C-API: File callbacks
*
*  Actually, it's a data structure to wrap a set of fXXXX (e.g fopen)
*  replacement functions.
*
*  The default implementation of the functions utilizes the fXXX functions from
*  the CRT. However, you can supply a custom implementation to Assimp by
*  delivering a custom aiFileIO. Use this to enable reading from other sources,
*  such as ZIP archives or memory locations. */
File :: struct {
    /** Callback to read from a file */
    ReadProc:     File_Read_Proc,

    /** Callback to write to a file */
    WriteProc:    File_Write_Proc,

    /** Callback to retrieve the current position of
	*  the file cursor (ftell())
	*/
    TellProc:     File_Tell_Proc,

    /** Callback to retrieve the size of the file,
	*  in bytes
	*/
    FileSizeProc: File_Tell_Proc,

    /** Callback to set the current position
	* of the file cursor (fseek())
	*/
    SeekProc:     File_Seek,

    /** Callback to flush the file contents
	*/
    FlushProc:    File_Flush_Proc,

    /** User-defined, opaque data
	*/
    UserData:     User_Data,
}
