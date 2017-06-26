[![Platforms](https://img.shields.io/badge/platform-linux-lightgrey.svg)](https://swift.org)
[![Release tag](https://img.shields.io/github/release/kelvin13/swift-opengl.svg)](https://github.com/kelvin13/swift-opengl/releases)
[![Build](https://travis-ci.org/kelvin13/swift-opengl.svg?branch=master)](https://travis-ci.org/kelvin13/swift-opengl)
[![Issues](https://img.shields.io/github/issues/kelvin13/swift-opengl.svg)](https://github.com/kelvin13/swift-opengl/issues?state=open)
[![Language](https://img.shields.io/badge/version-swift_4-ffa020.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-GPL3-ff3079.svg)](https://github.com/kelvin13/swift-opengl/blob/master/COPYING)
[![Queen](https://img.shields.io/badge/taylor-swift-e030ff.svg)](https://www.google.com/search?q=where+is+ts6&oq=where+is+ts6)

# opengl

An OpenGL function loader written in pure swift. To use it, `import OpenGL` in your swift file.

*OpenGL* is a function loader which allows you to call OpenGL GPU functions from swift programs. These functions are loaded lazily at runtime by *OpenGL*. *OpenGL* also diagnoses invalid OpenGL function calls due to the function not being available on a particular GPU and OpenGL version. *OpenGL* can load any OpenGL function up to OpenGL 4.5.

*OpenGL* provides access to OpenGL functions both with labeled and unlabeled arguments. This can help you avoid common argument ordering bugs.

```swift
var tex_id:UInt32 = 0
glGenTextures(1, &tex_id)
glBindTexture(GL.TEXTURE_2D, tex_id)
glTexImage2D(target         : GL.TEXTURE_2D,
             level          : 0,
             internalformat : GL.RGBA8,
             width          : h,
             height         : k,
             border         : 0,
             format         : GL.RGBA,
             type           : GL.UNSIGNED_BYTE,
             pixels         : pixbuf)
glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE)
glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE)
```

*OpenGL* also provides typealias definitions for OpenGL types.

```swift
let tex_id1:GL.UInt
let tex_id2:UInt32
```

| OpenGL c type     | *OpenGL* swift typealias | *OpenGL* swift type |
| ----------------- | ----------------- | ------------------------- |
| GLboolean         | GL.Bool           | Bool                      |
| GLdouble          | GL.Double         | Double                    |
| GLclampd          | GL.ClampDouble    | Double                    |
| GLfloat           | GL.Float          | Float                     |
| GLclampf          | GL.ClampFloat     | Float                     |
| GLbyte            | GL.Byte           | Int8                      |
| GLchar            | GL.Char           | Int8                      |
| GLcharARB         | GL.CharARB        | Int8                      |
| GLshort           | GL.Short          | Int16                     |
| GLint             | GL.Int            | Int32                     |
| GLsizei           | GL.Size           | Int32                     |
| GLenum            | GL.Enum           | Int32                     |
| GLfixed           | GL.Fixed          | Int32                     |
| GLclampx          | GL.ClampX         | Int32                     |
| GLint64           | GL.Int64          | Int64                     |
| GLint64EXT        | GL.Int64EXT       | Int64                     |
| GLintptr          | GL.IntPointer     | Int                       |
| GLintptrARB       | GL.IntPointerARB  | Int                       |
| GLsizeiptr        | GL.SizePointer    | Int                       |
| GLsizeiptrARB     | GL.SizePointerARB | Int                       |
| GLvdpauSurfaceNV  | GL.VdpauSurfaceNV | Int                       |
| GLubyte           | GL.UByte          | UInt8                     |
| GLushort          | GL.UShort         | UInt16                    |
| GLhalfNV          | GL.HalfNV         | UInt16                    |
| GLuint            | GL.UInt           | UInt32                    |
| GLbitfield        | GL.Bitfield       | UInt32                    |
| GLuint64          | GL.UInt64         | UInt64                    |
| GLuint64EXT       | GL.UInt64EXT      | UInt64                    |
| GLhandleARB       | GL.HandleARB      | UnsafeMutableRawPointer?  |
| GLeglImageOES     | GL.EGLImageOES    | UnsafeMutableRawPointer?  |
| GLsync            | GL.Sync           | OpaquePointer?            |
