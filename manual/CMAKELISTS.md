## III. Generate and customize `CMakeLists.txt`

MakeKit automatically generates `CMakeLists.txt` files for your project using a wide variety of user-specified settings.

In the generated `CMakeLists.txt` files several MakeKit related variables and functions are available.

### Variables in `CMakeLists.txt`

| VARIABLE         | Description    | Value type          |
|:-----------------|:---------------|:--------------------|
| `MK_ASM`         | ASM support    | `BOOL`              |
| `MK_BOOST`       | Boost support  | `BOOST_LIST`        |
| `MK_CUDA`        | CUDA support   | `BOOL`              |
| `MK_OPENCL`      | OpenCL support | `BOOL`              |
| `MK_OPENGL`      | OpenGL support | `BOOL`              |
| `MK_OPENMP`      | OpenMP support | `BOOL`              |
| `MK_VULKAN`      | Vulkan support | `BOOL`              |
| `MK_QT`          | Qt 5 support   | `QT_LIST`           |
| `MK_MODULE_MODE` | Target type    | `TARGET`            |

#### Accepted values

- **`BOOL`**

`TRUE` (or alternatively `ON` `YES` `Yes` `yes` `Y` `y` `1`)
`FALSE` (or alternatively `OFF` `NO` `No` `no` `N` `n` `0`)

- **`TARGET`**

`NONE`
`EXECUTABLE`
`STATIC_LIBRARY`
`SHARED_LIBRARY`

- **`BOOST_LIST`**

`OFF`, or a list of the following values:

`accumulators`
`algorithm`
`align`
`any`
`array`
`asio`
`assert`
`assign`
`atomic`
`beast`
`bimap`
`bind`
`callable_traits`
`chrono`
`circular_buffer`
`compatibility`
`compute`
`concept_check`
`config`
`container`
`container_hash`
`context`
`contract`
`conversion`
`convert`
`core`
`coroutine`
`coroutine2`
`crc`
`date_time`
`detail`
`disjoint_sets`
`dll`
`dynamic_bitset`
`endian`
`exception`
`fiber`
`filesystem`
`flyweight`
`foreach`
`format`
`function`
`function_types`
`functional`
`fusion`
`geometry`
`gil`
`graph`
`graph_parallel`
`hana`
`heap`
`hof`
`icl`
`integer`
`interprocess`
`intrusive`
`io`
`iostreams`
`iterator`
`lambda`
`lexical_cast`
`local_function`
`locale`
`lockfree`
`log`
`logic`
`math`
`metaparse`
`move`
`mp11`
`mpi`
`mpl`
`msm`
`multi_array`
`multi_index`
`multiprecision`
`numeric`
`optional`
`parameter`
`phoenix`
`poly_collection`
`polygon`
`pool`
`predef`
`preprocessor`
`process`
`program_options`
`property_map`
`property_tree`
`proto`
`ptr_container`
`python`
`qvm`
`random`
`range`
`ratio`
`rational`
`regex`
`scope_exit`
`serialization`
`signals`
`signals2`
`smart_ptr`
`sort`
`spirit`
`stacktrace`
`statechart`
`static_assert`
`system`
`test`
`thread`
`throw_exception`
`timer`
`tokenizer`
`tti`
`tuple`
`type_erasure`
`type_index`
`type_traits`
`typeof`
`units`
`unordered`
`utility`
`uuid`
`variant`
`vmd`
`wave`
`winapi`
`xpressive`
`yap`

More info: https://www.boost.org/doc/libs/1_67_0

- **`QT_LIST`**

`OFF`, or a list of the following values:

`Bluetooth`
`Charts`
`Concurrent`
`Core`
`DataVisualization`
`DBus`
`Designer`
`Gamepad`
`Gui`
`Help`
`LinguistTools`
`Location`
`MacExtras`
`Multimedia`
`MultimediaWidgets`
`Network`
`NetworkAuth`
`Nfc`
`OpenGL`
`OpenGLExtensions`
`Positioning`
`PositioningQuick`
`PrintSupport`
`Purchasing`
`Qml`
`Quick`
`QuickCompiler`
`QuickControls2`
`QuickTest`
`QuickWidgets`
`RemoteObjects`
`RepParser`
`Script`
`ScriptTools`
`Scxml`
`Sensors`
`SerialBus`
`SerialPort`
`Sql`
`Svg`
`Test`
`TextToSpeech`
`UiPlugin`
`UiTools`
`WebChannel`
`WebEngine`
`WebEngineCore`
`WebEngineWidgets`
`WebSockets`
`WebView`
`Widgets`
`Xml`
`XmlPatterns`
`3DAnimation`
`3DCore`
`3DExtras`
`3DInput`
`3DLogic`
`3DQuick`
`3DQuickAnimation`
`3DQuickExtras`
`3DQuickInput`
`3DQuickRender`
`3DQuickScene2D`
`3DRender`

More info: http://doc.qt.io/qt-5/qtmodules.html

### Functions in `CMakeLists.txt`

**`mk_add_imported_library(NAME MODE INCLUDE_DIRECTORY STATIC_IMPORT SHARED_IMPORT)`**

Add an imported library using the name `NAME`.

**`mk_deploy()`**

Perform a post-build deploy step to the runtime output directory (`bin`).

**`mk_deploy_list()`**

Generate a `.txt` file containing the required deploy files into the target build directories.
