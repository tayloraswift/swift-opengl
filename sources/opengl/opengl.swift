public
typealias GLDebugProc = @convention(c)
    (Int32, Int32, UInt32, Int32, Int32, UnsafePointer<Int8>, UnsafeRawPointer) -> Void
public
typealias GLDebugProcARB = GLDebugProc
public
typealias GLDebugProcKHR = GLDebugProc

public
typealias GLDebugProcAMD = @convention(c)
    (Int32, Int32, Int32, Int32, UnsafePointer<Int8>, UnsafeMutableRawPointer) -> Void


func get_fp(_ name:String, support:[String]) -> UnsafeMutableRawPointer
{
    guard let fp:UnsafeMutableRawPointer = lookup_address(of: name)
    else
    {
        fatalError("failed to load function \(name)\n\(support.joined(separator: "\n"))")
    }
    return fp
}

#if os(Linux)
    import Glibc

    var glx_get_proc_address:(@convention(c) (UnsafePointer<Int8>) -> UnsafeMutableRawPointer?)? = nil

    func lookup_address(of name:String) -> UnsafeMutableRawPointer?
    {
        if let glx_get_proc_address = glx_get_proc_address
        {
            return glx_get_proc_address(name)
        }

        guard let dlopenhandle:UnsafeMutableRawPointer = dlopen(nil, RTLD_LAZY | RTLD_LOCAL)
        else
        {
            fatalError("failed to obtain dynamic library handle")
        }
        if let fp:UnsafeMutableRawPointer = dlsym(dlopenhandle, "glXGetProcAddressARB")
        {
            glx_get_proc_address = unsafeBitCast(fp, to: type(of: glx_get_proc_address))
        }

        if let glx_get_proc_address = glx_get_proc_address
        {
            return glx_get_proc_address(name)
        }

        if let fp:UnsafeMutableRawPointer = dlsym(dlopenhandle, "glXGetProcAddress")
        {
            glx_get_proc_address = unsafeBitCast(fp, to: type(of: glx_get_proc_address))
        }

        if let glx_get_proc_address = glx_get_proc_address
        {
            return glx_get_proc_address(name)
        }

        fatalError("failed to find glXGetProcAddress")
    }

#elseif os(OSX)
    import Darwin

    let framework:String = "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
    var dlopenhandle:UnsafeMutableRawPointer? = nil

    func lookup_address(of name:String) -> UnsafeMutableRawPointer?
    {
        if let dlopenhandle:UnsafeMutableRawPointer = dlopenhandle
        {
            return dlsym(dlopenhandle, name)
        }

        dlopenhandle = dlopen(framework, RTLD_LAZY)

        if let dlopenhandle:UnsafeMutableRawPointer = dlopenhandle
        {
            return dlsym(dlopenhandle, name)
        }

        fatalError("failed to load opengl framework")
    }

#else
    func lookup_address(of _:String) -> UnsafeMutableRawPointer?
    {
        fatalError("unsupported OS")
    }

#endif
