[![Platforms](https://img.shields.io/badge/platform-linux-lightgrey.svg)](https://swift.org)
[![Release tag](https://img.shields.io/github/release/kelvin13/swift-opengl.svg)](https://github.com/kelvin13/swift-opengl/releases)
[![Build](https://travis-ci.org/kelvin13/swift-opengl.svg?branch=master)](https://travis-ci.org/kelvin13/swift-opengl)
[![Issues](https://img.shields.io/github/issues/kelvin13/swift-opengl.svg)](https://github.com/kelvin13/swift-opengl/issues?state=open)
[![Language](https://img.shields.io/badge/version-swift_4-ffa020.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-GPL3-ff3079.svg)](https://github.com/kelvin13/swift-opengl/blob/master/COPYING)
[![Queen](https://img.shields.io/badge/taylor-swift-e030ff.svg)](https://www.google.com/search?q=where+is+ts6&oq=where+is+ts6)

# OpenGL

An OpenGL function loader written in pure swift. To use it, `import OpenGL` in your swift file.

*OpenGL* is a function loader which allows you to call OpenGL GPU functions from swift programs. These functions are loaded lazily at runtime by *OpenGL*. *OpenGL* also diagnoses invalid OpenGL function calls due to the function not being available on a particular GPU and OpenGL version. *OpenGL* can load any OpenGL function up to OpenGL 4.5.

*OpenGL* works on Linux; it’s untested on Mac OSX, but there is no reason it shouldn’t work.

## Functions

*OpenGL* provides access to OpenGL functions both with labeled and unlabeled arguments. This can help you avoid common argument ordering bugs. 

```swift
glClearColor(0.15, 0.15, 0.15, 1)
glClearColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
```

The function names are the same as the OpenGL C specification, and the argument labels are the same as the parameter names in the C specification, with two exceptions: `` `in`: `` has been renamed to `input:`, and `` `func`: `` has been renamed to `f:` to avoid conflicts with Swift keywords.

## Constants

*OpenGL* imports OpenGL constants under the scope `GL`. Unless doing so would cause the constant’s name to start with a digit, the constant’s redundant `GL_` prefix is dropped.

```swift
glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
```

All *OpenGL* constants are of one of the following types: `GL.Enum`, `GL.Bitfield`, or `GL.UInt64`. (`Int32`, `UInt32`, or `UInt64`, respectively.)

## Types

*OpenGL* provides typealias definitions for OpenGL types. The typealiases are given Swifty names, and are also scoped to `GL`.

```swift
var tex_id:GL.UInt = 0
```

| OpenGL C type     | *OpenGL* Swift typealias | *OpenGL* Swift type |
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
