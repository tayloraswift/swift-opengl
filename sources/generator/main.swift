/*
    Copyright 2017, Kelvin Ma (“taylorswift”), kelvin13ma@gmail.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import XML

#if os(Linux)
    import Glibc

#elseif os(OSX)
    import Darwin

#else
    fatalError("Unsupported OS")

#endif

let DEFINITION_FILE_PATH:String = "sources/generator/gl.xml"

let LICENSE:String =
"""
/*
    THIS FILE IS GENERATED. ALL MODIFICATIONS MAY BE LOST!

    Copyright 2017, Kelvin Ma (“taylorswift”), kelvin13ma@gmail.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
"""

extension String
{
    init(_ buffer:[Unicode.Scalar])
    {
        self.init(buffer.map(Character.init))
    }

    var rstripped:String
    {
        var str:String = self
        while let c:Character = str.last
        {
            guard c == " " || c == "\n"
            else
            {
                break
            }

            str.removeLast()
        }

        return str
    }
}

enum Node:String, Equatable
{
    case extensions,
         `extension`,
         require,
         commands,
         command,
         feature,
         remove,
         groups,
         group,
         enums,
         `enum`,
         param,
         proto,
         ptype,
         name,

    // unused
         types,
         type,
         apientry,
         glx,
         vecequiv,
         alias,
         unused,
         comment
}

func ~=(_ a:[Node], _ b:[Node]) -> Bool
{
    return a == b
}

struct DefinitionParser:XMLParser
{
    private
    enum Version:CustomStringConvertible
    {
        case gl(Int, Int), gles(Int, Int)

        var description:String
        {
            switch self
            {
            case .gl(let v1, let v2):
                return "OpenGL \(v1).\(v2)"
            case .gles(let v1, let v2):
                return "OpenGL ES \(v1).\(v2)"
            }
        }

        static
        func ==(_ a:Version, _ b:Version) -> Bool
        {
            switch a
            {
            case .gl(let v1, let v2):
                if case .gl(let u1, let u2) = b
                {
                    return v1 == u1 && v2 == u2
                }
                else
                {
                    return false
                }
            case .gles(let v1, let v2):
                if case .gles(let u1, let u2) = b
                {
                    return v1 == u1 && v2 == u2
                }
                else
                {
                    return false
                }
            }
        }
    }

    private
    enum Support:CustomStringConvertible
    {
        case added(Version), removed(Version), ext(String)

        var description:String
        {
            switch self
            {
            case .added(let version):
                return "Available since \(version)"
            case .removed(let version):
                return "Unavailable since \(version)"
            case .ext(let name):
                return "Available in extension '\(name)'"
            }
        }

        static
        func ==(_ a:Support, _ b:Support) -> Bool
        {
            switch a
            {
            case .added(let version1):
                if case .added(let version2) = b
                {
                    return version1 == version2
                }
                else
                {
                    return false
                }

            case .removed(let version1):
                if case .removed(let version2) = b
                {
                    return version1 == version2
                }
                else
                {
                    return false
                }

            case .ext:
                if case .ext = b
                {
                    return true
                }
                else
                {
                    return false
                }
            }
        }
    }

    private
    enum GLType:String
    {
        case none = "",
             GLbitfield,
             GLboolean,
             GLbyte,
             GLchar,
             GLcharARB,
             GLclampd,
             GLclampf,
             GLclampx,
             GLDEBUGPROC,
             GLDEBUGPROCAMD,
             GLDEBUGPROCARB,
             GLDEBUGPROCKHR,
             GLdouble,
             GLeglImageOES,
             GLenum,
             GLfixed,
             GLfloat,
             GLhalfNV,
             GLhandleARB,
             GLint,
             GLint64,
             GLint64EXT,
             GLintptr,
             GLintptrARB,
             GLshort,
             GLsizei,
             GLsizeiptr,
             GLsizeiptrARB,
             GLsync,
             GLubyte,
             GLuint,
             GLuint64,
             GLuint64EXT,
             GLushort,
             GLvdpauSurfaceNV,
             GLvoid,
             struct__cl_context = "struct _cl_context",
             struct__cl_event   = "struct _cl_event",

             void                    = "void",
             unsafemutablerawpointer = "void *",
             unsafemutablepointer_u8 = "GLubyte *"

        var swift_type:String
        {
            switch self
            {
            case .GLboolean:
                return "GL.Bool"
            case .GLdouble:
                return "GL.Double"
            case .GLclampd:
                return "GL.ClampDouble"
            case .GLfloat:
                return "GL.Float"
            case .GLclampf:
                return "GL.ClampFloat"
            case .GLbyte:
                return "GL.Byte"
            case .GLchar:
                return "GL.Char"
            case .GLcharARB:
                return "GL.CharARB"
            case .GLshort:
                return "GL.Short"
            case .GLint:
                return "GL.Int"
            case .GLsizei:
                return "GL.Size"
            case .GLenum:
                return "GL.Enum"
            case .GLfixed:
                return "GL.Fixed"
            case .GLclampx:
                return "GL.ClampX"
            case .GLint64:
                return "GL.Int64"
            case .GLint64EXT:
                return "GL.Int64EXT"
            case .GLintptr:
                return "GL.IntPointer"
            case .GLintptrARB:
                return "GL.IntPointerARB"
            case .GLsizeiptr:
                return "GL.SizePointer"
            case .GLsizeiptrARB:
                return "GL.SizePointerARB"
            case .GLvdpauSurfaceNV:
                return "GL.VdpauSurfaceNV"
            case .GLubyte:
                return "GL.UByte"
            case .GLushort:
                return "GL.UShort"
            case .GLhalfNV:
                return "GL.HalfNV"
            case .GLuint:
                return "GL.UInt"
            case .GLbitfield:
                return "GL.Bitfield"
            case .GLuint64:
                return "GL.UInt64"
            case .GLuint64EXT:
                return "GL.UInt64EXT"

            case .GLDEBUGPROC:
                return "GL.DebugProc"
            case .GLDEBUGPROCAMD:
                return "GL.DebugProcAMD"
            case .GLDEBUGPROCARB:
                return "GL.DebugProcARB"
            case .GLDEBUGPROCKHR:
                return "GL.DebugProcKHR"

            case .GLhandleARB:
                return "GL.HandleARB"
            case .GLeglImageOES:
                return "GL.EGLImageOES"

            case .GLsync:
                return "GL.Sync"

            case .struct__cl_context, .struct__cl_event:
                return "OpaquePointer?"
            case .unsafemutablerawpointer:
                return "UnsafeMutableRawPointer?"
            case .unsafemutablepointer_u8:
                return "UnsafeMutablePointer<UInt8>?"
            case .void, .GLvoid:
                return "()"

            case .none:
                fatalError("unreachable")
            }
        }
    }

    private
    enum PointerType:String
    {
        case none                       = "",
             mutable                    = "*",
             mutable_raw                = "void*",
             immutable                  = "const*",
             immutable_raw              = "constvoid*",

             mutable_mutable_raw        = "void**",
             mutable_immutable          = "const**",
             mutable_immutable_raw      = "constvoid**",
             immutable_immutable        = "const*const*",
             immutable_immutable_raw    = "constvoid*const*",

             array_2                    = "[2]"
    }

    private
    struct CurrentCommand
    {
        var name:String?            = nil,
            return_type:String      = "",
            parameters:[Parameter]  = []
    }

    private
    struct Command
    {
        let name:String,
            return_type:GLType,
            parameters:[Parameter]

        init(_ command:CurrentCommand)
        {
            guard let name:String = command.name
            else
            {
                fatalError("command '' has no name")
            }

            guard let return_type:GLType = GLType(rawValue: command.return_type)
            else
            {
                fatalError("command '\(name)' has an invalid return type '\(command.return_type)'")
            }

            self.name        = name
            self.return_type = return_type
            self.parameters  = command.parameters
        }
    }

    private
    struct CurrentParameter
    {
        var name   :String  = "",
            type   :String  = "",
            pointer:String  = "",
            group  :String? = nil,
            length :String? = nil
    }

    private
    struct Parameter
    {
        let name:String,
            type:GLType

        private
        let pointer:PointerType,
            group  :String?,
            length :String?

        var swift_type:String
        {
            switch self.pointer
            {
            case .none:
                return self.type.swift_type

            case .mutable:
                if self.type != .GLvoid
                {
                    return "UnsafeMutablePointer<\(self.type.swift_type)>?"
                }
                fallthrough

            case .mutable_raw:
                return "UnsafeMutableRawPointer?"

            case .immutable, .array_2:
                return "UnsafePointer<\(self.type.swift_type)>?"

            case .immutable_raw:
                return "UnsafeRawPointer?"

            case .mutable_mutable_raw:
                return "UnsafeMutablePointer<UnsafeMutableRawPointer?>?"

            case .mutable_immutable:
                return "UnsafeMutablePointer<UnsafeMutablePointer<\(self.type.swift_type)>?>?"

            case .mutable_immutable_raw:
                return "UnsafeMutablePointer<UnsafeRawPointer?>?"

            case .immutable_immutable:
                return "UnsafePointer<UnsafePointer<\(self.type.swift_type)>?>?"

            case .immutable_immutable_raw:
                return "UnsafePointer<UnsafeRawPointer?>?"
            }
        }

        init(_ parameter:CurrentParameter)
        {
            guard !parameter.name.isEmpty
            else
            {
                fatalError("command '' has no name")
            }

            guard let param_type:GLType = GLType(rawValue: parameter.type)
            else
            {
                fatalError("parameter '\(parameter.name)' has an invalid type '\(parameter.type)'")
            }

            guard let pointer_type:PointerType = PointerType(rawValue: parameter.pointer)
            else
            {
                fatalError("parameter '\(parameter.name)' has an invalid pointer type '\(parameter.pointer)'")
            }

            // fix parameter names that are Swift keywords
            if parameter.name == "func"
            {
                self.name = "f"
            }
            else if parameter.name == "in"
            {
                self.name = "input"
            }
            else
            {
                self.name    = parameter.name
            }
            self.type    = param_type
            self.pointer = pointer_type
            self.group   = parameter.group
            self.length  = parameter.length
        }
    }

    private
    var path:[Node] = [],

        constants:[(String, String, String)] = [ ],
        commands:[Command]                   = [ ],
        command_support:[String: [Support]]  = [:],

        //current_group:String           = "",
        //groups:[String: [String]]      = [:],

        current_constant_is_bitmask:Bool = false,

        current_command:CurrentCommand?  = nil,
        current_param:CurrentParameter?  = nil,
        current_version:Version?         = nil,
        current_extension:Support?       = nil

    mutating
    func handle_data(data:[Unicode.Scalar])
    {
        let str:String = String(data)
        switch self.path
        {
        // it is important to note that return type declarations only ever have
        // “const” or “void” occur before the <ptype> element appears, if any.
        // the “const” can be ignored, and the “void” will never be followed by
        // any <ptype> element.
        case [Node.commands, Node.command, Node.proto]:
            self.current_command?.return_type += str.rstripped

        case [Node.commands, Node.command, Node.proto, Node.ptype]:
            self.current_command?.return_type = str

        case [.commands, .command, .proto, .name]:
            self.current_command?.name = str

        case [.commands, .command, .param]:
            self.current_param?.pointer += str.filter{ $0 != " " }

        case [.commands, .command, .param, .ptype]:
            self.current_param?.type = str

        case [.commands, .command, .param, .name]:
            self.current_param?.name = str

        default:
            break
        }
    }

    mutating
    func handle_tag_start(name:String, attributes:[String: String])
    {
        guard name != "registry"
        else
        {
            return
        }

        guard let node_type:Node = Node(rawValue: name)
        else
        {
            print("unrecognized: \(name)")
            return
        }

        self.path.append(node_type)

        switch self.path
        {
        case [.extensions, .extension]:
            var extn:String = attributes["name"]!
            if extn.starts(with: "GL_")
            {
                extn.removeFirst(3)
            }
            self.current_extension = .ext(extn)

        case [.extensions, .extension, .require, .command]:
            let command:String = attributes["name"]!
            self.command_support[command, default: []].append(self.current_extension!)

        case [.feature]:
            guard let version_str:String = attributes["number"],
                  let decimal:String.Index = version_str.index(of: "."),
                  let v1:Int = Int(String(version_str[..<decimal])),
                  let v2:Int = Int(String(version_str[version_str.index(after: decimal)...]))
            else
            {
                fatalError("invalid feature number")
            }

            switch attributes["api"]!
            {
            case "gl":
                self.current_version = .gl(v1, v2)
            case "gles1", "gles2":
                self.current_version = .gles(v1, v2)
            default:
                fatalError("invalid feature api")
            }

        case [.feature, .require, .command]:
            let command:String = attributes["name"]!
            guard let version:Version = self.current_version
            else
            {
                fatalError("unreachable")
            }

            if version == .gles(2, 0)
            {
                if let index:Int = self.command_support[command]?.index(where: { $0 == .added(.gles(1, 0)) })
                {
                    self.command_support[command]?[index] = .added(version)
                    break
                }
            }
            else if version == .gles(1, 0)
            {
                if self.command_support[command]?.contains(where: { $0 == .added(.gles(2, 0)) }) ?? false
                {
                    break
                }
            }

            self.command_support[command, default: []].append(.added(version))

        case [.feature, .remove, .command]:
            let command:String = attributes["name"]!
            self.command_support[command, default: []].append(.removed(self.current_version!))

        /*
        case [.groups, .group]:
            self.current_group = attributes["name"]!
            self.groups[self.current_group] = []

        case [.groups, .group, .enum]:
            self.groups[self.current_group]!.append(attributes["name"]!)
        */

        case [.enums]:
            self.current_constant_is_bitmask = attributes["type"] == "bitmask" ||
                // OcclusionQueryEventMaskAMD has buggy record
                attributes["namespace"] == "OcclusionQueryEventMaskAMD"

        case [.enums, .enum]:
            var name:String = attributes["name"]!
            if let api:String = attributes["api"]
            {
                // GL_ACTIVE_PROGRAM_EXT has two different values
                name += "_" + api
            }

            if name.starts(with: "GL_")
            {
                name.removeFirst(3)
            }

            let int_type:String

            if attributes["type"] == "u"
            {
                int_type = "UInt32"
            }
            else if attributes["type"] == "ull"
            {
                int_type = "UInt64"
            }
            else
            {
                int_type = self.current_constant_is_bitmask ? "UInt32" : "Int32"
            }

            self.constants.append((name, int_type, attributes["value"]!))

        case [.commands, .command]:
            self.current_command = CurrentCommand()

        case [.commands, .command, .param]:
            self.current_param         = CurrentParameter()
            self.current_param?.length = attributes["len"]
            self.current_param?.group  = attributes["group"]

        default:
            break
        }
    }

    mutating
    func handle_tag_empty(name:String, attributes:[String: String])
    {
        self.handle_tag_start(name: name, attributes: attributes)
        self.handle_tag_end(name: name)
    }

    mutating
    func handle_tag_end(name:String)
    {
        guard name != "registry"
        else
        {
            return
        }

        switch self.path
        {
        case [.commands, .command]:
            guard let current_command = self.current_command
            else
            {
                fatalError("unreachable")
            }
            self.commands.append(Command(current_command))
            self.current_command = nil

        case [.commands, .command, .param]:
            guard let current_param = self.current_param
            else
            {
                fatalError("unreachable")
            }
            self.current_command?.parameters.append(Parameter(current_param))
            self.current_param = nil

        case [.feature]:
            self.current_version = nil

        case [.extensions, .extension]:
            self.current_extension = nil

        default:
            break
        }

        guard let node_type:Node = Node(rawValue: name)
        else
        {
            print("unrecognized: \(name)")
            return
        }

        guard self.path.removeLast() == node_type
        else
        {
            fatalError("malformed XML, mismatched tag '\(name)'")
        }
    }

    mutating
    func handle_processing_instruction(target:String, data:[Unicode.Scalar]) { }

    mutating
    func handle_error(_ message:String, line:Int, column:Int)
    {
        fatalError("\(DEFINITION_FILE_PATH):\(line):\(column): \(message)")
    }


    func generate_constants(stream:UnsafeMutablePointer<FILE>)
    {
        fputs(LICENSE, stream)
        fputs("""

            public
            enum GL
            {
                // note: GL.Int is Swift.Int32, not Swift.Int, and
                // GL.UInt is Swift.UInt32, not Swift.UInt
                public typealias Bool               = Swift.Bool
                public typealias Double             = Swift.Double
                public typealias ClampDouble        = Swift.Double
                public typealias Float              = Swift.Float
                public typealias ClampFloat         = Swift.Float
                public typealias Byte               = Swift.Int8
                public typealias Char               = Swift.Int8
                public typealias CharARB            = Swift.Int8
                public typealias Short              = Swift.Int16
                public typealias Int                = Swift.Int32
                public typealias Size               = Swift.Int32
                public typealias Enum               = Swift.Int32
                public typealias Fixed              = Swift.Int32
                public typealias ClampX             = Swift.Int32
                public typealias Int64              = Swift.Int64
                public typealias Int64EXT           = Swift.Int64
                public typealias IntPointer         = Swift.Int
                public typealias IntPointerARB      = Swift.Int
                public typealias SizePointer        = Swift.Int
                public typealias SizePointerARB     = Swift.Int
                public typealias VdpauSurfaceNV     = Swift.Int
                public typealias UByte              = Swift.UInt8
                public typealias UShort             = Swift.UInt16
                public typealias HalfNV             = Swift.UInt16
                public typealias UInt               = Swift.UInt32
                public typealias Bitfield           = Swift.UInt32
                public typealias UInt64             = Swift.UInt64
                public typealias UInt64EXT          = Swift.UInt64
                public typealias HandleARB          = UnsafeMutableRawPointer?
                public typealias EGLImageOES        = UnsafeMutableRawPointer?
                public typealias Sync               = OpaquePointer?

                public typealias DebugProc = @convention(c)
                    (Swift.Int32, Swift.Int32, Swift.UInt32, Swift.Int32, Swift.Int32, UnsafePointer<Swift.Int8>?, UnsafeRawPointer?) -> ()
                public typealias DebugProcARB = DebugProc
                public typealias DebugProcKHR = DebugProc

                public typealias DebugProcAMD = @convention(c)
                    (Swift.Int32, Swift.Int32, Swift.Int32, Swift.Int32, UnsafePointer<Swift.Int8>?, UnsafeMutableRawPointer?) -> ()


            """, stream)

        var first:Bool = true
        for (name, int_type, value):(String, String, String) in self.constants
        {
            if first
            {
                fputs("    public static \n    let ", stream)
                first = false
            }
            else
            {
                fputs(", \n        ", stream)
            }

            fputs("\(name):Swift.\(int_type) = \(value)", stream)
        }
        fputs("\n}\n", stream)
    }

    func generate_loader(stream:UnsafeMutablePointer<FILE>)
    {
        fputs(LICENSE, stream)
        fputs("\n\n", stream)

        let support_strs:[String] = Set<String>(self.command_support.values.lazy.flatMap{ $0 }.map{ $0.description }).sorted()
        let str_indices:[String: Int] = Dictionary(uniqueKeysWithValues: support_strs.lazy.enumerated().map{ ($0.1, $0.0) })

        var first:Bool = true
        for (i, support_str):(Int, String) in support_strs.enumerated()
        {
            if first
            {
                fputs("let ", stream)
                first = false
            }
            else
            {
                fputs(", \n    ", stream)
            }

            fputs("ss\(i):String = \"\(support_str)\"", stream)
        }
        fputs("""


                // OpenGL function loaders; functions are loaded lazily and replace
                // themselves with their loaded versions on first call

                """, stream)

        for command in self.commands
        {
            let arguments:String      = command.parameters.map{ $0.name }.joined(separator: ", "),
                types:String          = command.parameters.map{ $0.swift_type }.joined(separator: ", "),
                parameter_list:String = command.parameters.map{ "\($0.name):\($0.swift_type)" }.joined(separator: ", "),
                anon_list:String      = command.parameters.map{ "_ \($0.name):\($0.swift_type)" }.joined(separator: ", "),

                ret:String            = (command.return_type != .void && command.return_type != .GLvoid) ?
                                            " -> \(command.return_type.swift_type)" : "",
                support:String        = self.command_support[command.name]!
                                            .map{ "ss\(str_indices[$0.description]!)" }
                                            .joined(separator: ", ")

            fputs("""
            var fp_\(command.name):@convention(c) (\(types)) -> \(command.return_type.swift_type) = load_\(command.name)
            func load_\(command.name)(\(parameter_list))\(ret)
            {
                fp_\(command.name) = unsafeBitCast(get_fp(\"\(command.name)\", support: [\(support)]), to: Swift.type(of: fp_\(command.name)))
                \(ret.isEmpty ? "" : "return ")fp_\(command.name)(\(arguments))
            }
            public
            func \(command.name)(\(parameter_list))\(ret)
            {
                \(ret.isEmpty ? "" : "return ")fp_\(command.name)(\(arguments))
            }
            """, stream)

            if !command.parameters.isEmpty
            {
                fputs("""

                public
                func \(command.name)(\(anon_list))\(ret)
                {
                    \(ret.isEmpty ? "" : "return ")fp_\(command.name)(\(arguments))
                }
                """, stream)
            }

            fputs("\n\n", stream)
        }
    }
}

var parser:DefinitionParser = DefinitionParser()
parser.parse(path: DEFINITION_FILE_PATH)

// write constants file
guard let stream_constants:UnsafeMutablePointer<FILE> = fopen("sources/opengl/constants.swift", "w")
else
{
    fatalError("failed to open stream")
}
parser.generate_constants(stream: stream_constants)

// write loader file
guard let stream_loader:UnsafeMutablePointer<FILE> = fopen("sources/opengl/loader.swift", "w")
else
{
    fatalError("failed to open stream")
}
parser.generate_loader(stream: stream_loader)
