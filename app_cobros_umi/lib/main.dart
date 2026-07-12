import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MiAppCobros());
}

class MiAppCobros extends StatelessWidget {
  const MiAppCobros({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cobros Umi',
      theme: ThemeData(useMaterial3: true),
      home: const PantallaPrincipal(),
    );
  }
}

class FormateadorMilesCRC extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    String solamenteNumeros = newValue.text.replaceAll('.', '');
    final buffer = StringBuffer();
    for (int i = 0; i < solamenteNumeros.length; i++) {
      if (i > 0 && (solamenteNumeros.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(solamenteNumeros[i]);
    }
    String textoFormateado = buffer.toString();
    return newValue.copyWith(
      text: textoFormateado,
      selection: TextSelection.collapsed(offset: textoFormateado.length),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  // --- ESTADO GLOBAL ---
  String _nombreEmpresa = "Cobros Umi";
  String _urlLogoEmpresa = "";
  String _urlImagenFondo = "";
  Color _colorFondoApp = const Color(0xFF0F172A);
  Color _colorTarjetas = const Color(0xFF1E293B);
  Color _colorBotonesYDetalles = const Color(0xFF38BDF8);
  Color _colorTextoPrincipal = Colors.white;
  String _temaPreconfiguradoActual = "Azul Cielo";

  double _saldoRealBanco = 1180650.0;
  int _pestanaActual = 0;

  // Controladores
  final TextEditingController _nombreEmpresaController =
      TextEditingController();
  final TextEditingController _urlLogoController = TextEditingController();
  final TextEditingController _urlFondoController = TextEditingController();
  final TextEditingController _nuevoNombreRubroController =
      TextEditingController();
  final TextEditingController _montoMetaController = TextEditingController();
  final TextEditingController _montoOperacionController =
      TextEditingController();
  final TextEditingController _saldoBancoController = TextEditingController();

  List<Map<String, dynamic>> misRubros = [
    {'nombre': 'MANT. CARRO', 'acumulado': 0.0, 'meta': 30000.0},
    {'nombre': 'CUOTA MANT', 'acumulado': 0.0, 'meta': 81600.0},
    {'nombre': 'TELEFONOS', 'acumulado': 0.0, 'meta': 60000.0},
    {'nombre': 'LIMPIEZA', 'acumulado': 0.0, 'meta': 88000.0},
    {'nombre': 'CABLE-INTERNET', 'acumulado': 0.0, 'meta': 44000.0},
    {'nombre': 'LUZ', 'acumulado': 0.0, 'meta': 60000.0},
    {'nombre': 'Seg. Tobosi', 'acumulado': 0.0, 'meta': 12000.0},
    {'nombre': 'COMEDERA', 'acumulado': 0.0, 'meta': 321000.0},
    {'nombre': 'Escuela chicos', 'acumulado': 0.0, 'meta': 484050.0},
  ];

  List<Map<String, dynamic>> historialReportes = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombreEmpresa', _nombreEmpresa);
    await prefs.setString('urlLogoEmpresa', _urlLogoEmpresa);
    await prefs.setString('urlImagenFondo', _urlImagenFondo);
    await prefs.setString('temaActual', _temaPreconfiguradoActual);
    await prefs.setDouble('saldoRealBanco', _saldoRealBanco);
    await prefs.setString('misRubros', jsonEncode(misRubros));
    await prefs.setString('historialReportes', jsonEncode(historialReportes));
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombreEmpresa = prefs.getString('nombreEmpresa') ?? "Cobros Umi";
      _urlLogoEmpresa = prefs.getString('urlLogoEmpresa') ?? "";
      _urlImagenFondo = prefs.getString('urlImagenFondo') ?? "";
      _temaPreconfiguradoActual = prefs.getString('temaActual') ?? "Azul Cielo";
      _saldoRealBanco = prefs.getDouble('saldoRealBanco') ?? 1180650.0;

      final seleccionados = _obtenerColoresTema(_temaPreconfiguradoActual);
      _colorFondoApp = seleccionados['fondo'] as Color;
      _colorTarjetas = seleccionados['tarjeta'] as Color;
      _colorBotonesYDetalles = seleccionados['detalle'] as Color;
      _colorTextoPrincipal = seleccionados['texto'] as Color;

      String? rubrosJson = prefs.getString('misRubros');
      if (rubrosJson != null) {
        try {
          List<dynamic> decodificado = jsonDecode(rubrosJson);
          if (decodificado.isNotEmpty && decodificado.first is Map) {
            misRubros = decodificado
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          }
        } catch (_) {}
      }

      String? historialJson = prefs.getString('historialReportes');
      if (historialJson != null) {
        try {
          List<dynamic> decodificadoH = jsonDecode(historialJson);
          historialReportes = decodificadoH
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } catch (_) {}
      }
    });
  }

  Map<String, dynamic> _obtenerColoresTema(String tema) {
    switch (tema) {
      case "Premium Oscuro":
        return {
          'fondo': const Color(0xFF0F1115),
          'tarjeta': const Color(0xFF1D2026),
          'detalle': const Color(0xFF10B981),
          'texto': Colors.white
        };
      case "Monteverde":
        return {
          'fondo': const Color(0xFF061A0C),
          'tarjeta': const Color(0xFF0F2E17),
          'detalle': const Color(0xFF34D399),
          'texto': Colors.white
        };
      case "Café Cálido":
        return {
          'fondo': const Color(0xFF1C1917),
          'tarjeta': const Color(0xFF292524),
          'detalle': const Color(0xFFF59E0B),
          'texto': Colors.white
        };
      case "Pastel Rosado":
        return {
          'fondo': const Color(0xFFFFF1F2),
          'tarjeta': Colors.white,
          'detalle': const Color(0xFFFB7185),
          'texto': const Color(0xFF4C0519)
        };
      case "Pastel Menta":
        return {
          'fondo': const Color(0xFFF0FDF4),
          'tarjeta': Colors.white,
          'detalle': const Color(0xFF22C55E),
          'texto': const Color(0xFF052E16)
        };
      case "Pastel Lavanda":
        return {
          'fondo': const Color(0xFFFAF5FF),
          'tarjeta': Colors.white,
          'detalle': const Color(0xFFA855F7),
          'texto': const Color(0xFF3B0764)
        };
      case "Pastel Vainilla":
        return {
          'fondo': const Color(0xFFFEFCE8),
          'tarjeta': Colors.white,
          'detalle': const Color(0xFFEAB308),
          'texto': const Color(0xFF422006)
        };
      default: // Azul Cielo
        return {
          'fondo': const Color(0xFF0F172A),
          'tarjeta': const Color(0xFF1E293B),
          'detalle': const Color(0xFF38BDF8),
          'texto': Colors.white
        };
    }
  }

  String _formatearMontoVista(double monto) {
    String nStr = monto.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < nStr.length; i++) {
      if (i > 0 && (nStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(nStr[i]);
    }
    return buffer.toString();
  }

  void _registrarEnHistorial(String rubro, String tipo, double monto) {
    final ahora = DateTime.now();
    final fechaStr =
        "${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')} ${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}";

    setState(() {
      historialReportes.insert(
          0, {'fecha': fechaStr, 'rubro': rubro, 'tipo': tipo, 'monto': monto});
    });
  }

  void _abrirOperacionSobre(int index, bool esIngreso) {
    _montoOperacionController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _colorTarjetas,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            esIngreso
                ? 'Apartar en: ${misRubros[index]['nombre']}'
                : 'Ejecutar pago de: ${misRubros[index]['nombre']}',
            style: TextStyle(
                color: _colorTextoPrincipal,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _montoOperacionController,
            keyboardType: TextInputType.number,
            style: TextStyle(
                color: _colorTextoPrincipal, fontWeight: FontWeight.bold),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              FormateadorMilesCRC()
            ],
            decoration: InputDecoration(
              prefixText: '₡ ',
              prefixStyle: TextStyle(color: _colorBotonesYDetalles),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _colorBotonesYDetalles)),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () {
                String valorLimpio =
                    _montoOperacionController.text.replaceAll('.', '').trim();
                double monto = double.tryParse(valorLimpio) ?? 0.0;

                if (monto > 0) {
                  setState(() {
                    if (esIngreso) {
                      misRubros[index]['acumulado'] += monto;
                      _registrarEnHistorial(
                          misRubros[index]['nombre'], 'INGRESO', monto);
                    } else {
                      misRubros[index]['acumulado'] -= monto;
                      _saldoRealBanco -= monto;
                      _registrarEnHistorial(
                          misRubros[index]['nombre'], 'PAGO', monto);
                    }
                  });
                  _guardarDatos();
                }
                Navigator.pop(context);
              },
              child: Text('Confirmar',
                  style: TextStyle(
                      color: _colorBotonesYDetalles,
                      fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  void _abrirEdicionRubro(int index) {
    _nuevoNombreRubroController.text = misRubros[index]['nombre'];
    _montoMetaController.text =
        (misRubros[index]['meta'] as double).toStringAsFixed(0);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _colorTarjetas,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Editar Sobre',
              style: TextStyle(
                  color: _colorTextoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NOMBRE DEL SOBRE',
                  style: TextStyle(
                      color: _colorBotonesYDetalles,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
              TextField(
                controller: _nuevoNombreRubroController,
                style: TextStyle(color: _colorTextoPrincipal),
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _colorBotonesYDetalles))),
              ),
              const SizedBox(height: 16),
              Text('META MENSUAL',
                  style: TextStyle(
                      color: _colorBotonesYDetalles,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
              TextField(
                controller: _montoMetaController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: _colorTextoPrincipal),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  FormateadorMilesCRC()
                ],
                decoration: InputDecoration(
                    prefixText: '₡ ',
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _colorBotonesYDetalles))),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () {
                String nuevoNombre =
                    _nuevoNombreRubroController.text.trim().toUpperCase();
                String metaLimpia =
                    _montoMetaController.text.replaceAll('.', '').trim();
                double nuevaMeta = double.tryParse(metaLimpia) ?? 0.0;

                if (nuevoNombre.isNotEmpty) {
                  setState(() {
                    misRubros[index]['nombre'] = nuevoNombre;
                    misRubros[index]['meta'] = nuevaMeta;
                  });
                  _guardarDatos();
                }
                Navigator.pop(context);
              },
              child: Text('Guardar',
                  style: TextStyle(
                      color: _colorBotonesYDetalles,
                      fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  void _ajustarSaldoBanco() {
    _saldoBancoController.text =
        _saldoRealBanco.toStringAsFixed(0).replaceAll('.', '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _colorTarjetas,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Sincronizar Balance del Banco',
              style: TextStyle(
                  color: _colorTextoPrincipal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _saldoBancoController,
            keyboardType: TextInputType.number,
            style: TextStyle(
                color: _colorTextoPrincipal, fontWeight: FontWeight.bold),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              FormateadorMilesCRC()
            ],
            decoration: InputDecoration(
              prefixText: '₡ ',
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _colorBotonesYDetalles)),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () {
                String valorLimpio =
                    _saldoBancoController.text.replaceAll('.', '').trim();
                setState(() {
                  _saldoRealBanco = double.tryParse(valorLimpio) ?? 0.0;
                });
                _guardarDatos();
                Navigator.pop(context);
              },
              child: Text('Actualizar',
                  style: TextStyle(
                      color: _colorBotonesYDetalles,
                      fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  void _eliminarRubro(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _colorTarjetas,
        title: Text('¿Eliminar sobre?',
            style: TextStyle(color: _colorTextoPrincipal)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() {
                misRubros.removeAt(index);
              });
              _guardarDatos();
              Navigator.pop(context);
            },
            child: const Text('Eliminar',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _mostrarMenuPersonalizacion(BuildContext context) {
    _nombreEmpresaController.text = _nombreEmpresa;
    _urlLogoController.text = _urlLogoEmpresa;
    _urlFondoController.text = _urlImagenFondo;
    String temaSeleccionadoEnModal = _temaPreconfiguradoActual;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              title: const Text('Personalizar Aplicación',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NOMBRE DE LA EMPRESA:',
                        style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                    TextField(
                      controller: _nombreEmpresaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30))),
                    ),
                    const SizedBox(height: 16),
                    const Text('URL / RUTA DEL LOGO:',
                        style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                    TextField(
                      controller: _urlLogoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: 'Ej: assets/logo.png',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 13),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30))),
                    ),
                    const SizedBox(height: 16),
                    const Text('URL DE IMAGEN DE FONDO (WHATSAPP STYLE):',
                        style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                    TextField(
                      controller: _urlFondoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: 'Pegá un link de imagen web aquí',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 13),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30))),
                    ),
                    const SizedBox(height: 16),
                    const Text('SELECCIONAR TEMA VISUAL:',
                        style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        "Azul Cielo",
                        "Premium Oscuro",
                        "Monteverde",
                        "Café Cálido",
                        "Pastel Rosado",
                        "Pastel Menta",
                        "Pastel Lavanda",
                        "Pastel Vainilla"
                      ].map((tema) {
                        bool esElActual = temaSeleccionadoEnModal == tema;
                        return InkWell(
                          onTap: () {
                            setModalState(() => temaSeleccionadoEnModal = tema);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: esElActual
                                  ? Colors.lightBlueAccent
                                  : Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: esElActual
                                      ? Colors.white
                                      : Colors.white24,
                                  width: 1.5),
                            ),
                            child: Text(
                              tema,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: esElActual ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Colors.grey))),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _nombreEmpresa = _nombreEmpresaController.text.trim();
                      _urlLogoEmpresa = _urlLogoController.text.trim();
                      _urlImagenFondo = _urlFondoController.text.trim();
                      _temaPreconfiguradoActual = temaSeleccionadoEnModal;
                      final seleccionados =
                          _obtenerColoresTema(_temaPreconfiguradoActual);
                      _colorFondoApp = seleccionados['fondo'] as Color;
                      _colorTarjetas = seleccionados['tarjeta'] as Color;
                      _colorBotonesYDetalles =
                          seleccionados['detalle'] as Color;
                      _colorTextoPrincipal = seleccionados['texto'] as Color;
                    });
                    _guardarDatos();
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar',
                      style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarFormularioNuevoRubro(BuildContext context) {
    _nuevoNombreRubroController.clear();
    _montoMetaController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _colorTarjetas,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nuevo Sobre de Provisión',
                  style: TextStyle(
                      color: _colorTextoPrincipal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('NOMBRE DEL SOBRE',
                  style: TextStyle(
                      color: _colorBotonesYDetalles,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
              TextField(
                controller: _nuevoNombreRubroController,
                style: TextStyle(color: _colorTextoPrincipal),
              ),
              const SizedBox(height: 20),
              Text('META MENSUAL DE REFERENCIA',
                  style: TextStyle(
                      color: _colorBotonesYDetalles,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
              TextField(
                controller: _montoMetaController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: _colorTextoPrincipal),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  FormateadorMilesCRC()
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _colorBotonesYDetalles,
                        foregroundColor: _colorFondoApp),
                    onPressed: () {
                      String nombre =
                          _nuevoNombreRubroController.text.trim().toUpperCase();
                      String metaLimpia =
                          _montoMetaController.text.replaceAll('.', '').trim();
                      double meta = double.tryParse(metaLimpia) ?? 0.0;
                      if (nombre.isNotEmpty) {
                        setState(() {
                          misRubros.add({
                            'nombre': nombre,
                            'acumulado': 0.0,
                            'meta': meta
                          });
                        });
                        _guardarDatos();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Crear Sobre',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _limpiarHistorialCompleto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _colorTarjetas,
        title: Text('¿Vaciar Historial?',
            style: TextStyle(color: _colorTextoPrincipal)),
        content: const Text(
            'Esta acción borrará todos los reportes registrados.',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() {
                historialReportes.clear();
              });
              _guardarDatos();
              Navigator.pop(context);
            },
            child: const Text('Borrar Todo',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalAcumuladoEnSobres =
        misRubros.fold(0, (suma, item) => suma + item['acumulado']);
    double dineroLibreColchon = _saldoRealBanco - totalAcumuladoEnSobres;

    return Scaffold(
      backgroundColor: _colorFondoApp,
      floatingActionButton: _pestanaActual == 0
          ? FloatingActionButton.extended(
              onPressed: () => _mostrarFormularioNuevoRubro(context),
              backgroundColor: _colorBotonesYDetalles,
              foregroundColor: _temaPreconfiguradoActual.contains("Pastel")
                  ? const Color(0xFF1E293B)
                  : _colorFondoApp,
              icon: const Icon(Icons.folder_open_rounded),
              label: const Text('Nuevo Sobre',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pestanaActual,
        backgroundColor: _colorTarjetas,
        selectedItemColor: _colorBotonesYDetalles,
        unselectedItemColor: _colorTextoPrincipal.withOpacity(0.4),
        onTap: (index) {
          setState(() {
            _pestanaActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.wallet_rounded), label: 'Mis Sobres'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_edu_rounded), label: 'Reportería'),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: _colorFondoApp,
          image: _urlImagenFondo.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(_urlImagenFondo),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(
                          _temaPreconfiguradoActual.contains("Pastel")
                              ? 0.15
                              : 0.4),
                      BlendMode.darken),
                )
              : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: _colorTarjetas.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.analytics_rounded,
                              color: _colorBotonesYDetalles, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(_nombreEmpresa,
                            style: TextStyle(
                                color: _colorTextoPrincipal,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        if (_pestanaActual == 1)
                          IconButton(
                            icon: const Icon(Icons.delete_sweep_rounded,
                                color: Colors.redAccent),
                            onPressed: _limpiarHistorialCompleto,
                          ),
                        IconButton(
                          icon: Icon(Icons.palette_rounded,
                              color: _colorBotonesYDetalles),
                          onPressed: () => _mostrarMenuPersonalizacion(context),
                        ),
                        IconButton(
                          icon: Icon(Icons.sync_alt_rounded,
                              color: _colorBotonesYDetalles),
                          onPressed: _ajustarSaldoBanco,
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // BALANCE CARD
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _colorTarjetas.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    Text('BALANCE TOTAL EN BANCO',
                        style: TextStyle(
                            color: _colorTextoPrincipal.withOpacity(0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('₡${_formatearMontoVista(_saldoRealBanco)}',
                        style: TextStyle(
                            color: _colorTextoPrincipal,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                    const Divider(height: 24, color: Colors.white24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('RESERVADO SOBRES',
                                style: TextStyle(
                                    color:
                                        _colorTextoPrincipal.withOpacity(0.6),
                                    fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(
                                '₡${_formatearMontoVista(totalAcumuladoEnSobres)}',
                                style: TextStyle(
                                    color: _colorTextoPrincipal,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('DISPONIBLE / LIBRE',
                                style: TextStyle(
                                    color: dineroLibreColchon >= 0
                                        ? Colors.green
                                        : Colors.redAccent,
                                    fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(
                              '₡${_formatearMontoVista(dineroLibreColchon)}',
                              style: TextStyle(
                                  color: dineroLibreColchon >= 0
                                      ? Colors.green
                                      : Colors.redAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),

              // VISTAS
              Expanded(
                child: _pestanaActual == 0
                    ? _construirVistaSobres()
                    : _construirVistaReporteria(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirVistaSobres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: _colorTarjetas.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8)),
            child: Text('MIS LÍNEAS DE PAGO (SOBRES)',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: _colorBotonesYDetalles)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: misRubros.length,
            itemBuilder: (context, index) {
              final rubro = misRubros[index];
              double metaMensual = rubro['meta'] ?? 0.0;
              double quincenalRef = metaMensual / 2;
              double progreso = rubro['acumulado'];

              // --- LÓGICA DE INDICADORES VISUALES ---
              Color colorMonto = _colorBotonesYDetalles;
              Widget iconoEstado = const SizedBox.shrink();

              if (metaMensual > 0) {
                if (progreso >= metaMensual) {
                  colorMonto = Colors.greenAccent;
                  iconoEstado = const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.check_circle_rounded,
                        color: Colors.greenAccent, size: 16),
                  );
                } else if (progreso >= quincenalRef) {
                  colorMonto = Colors.amberAccent;
                  iconoEstado = const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.local_fire_department_rounded,
                        color: Colors.amberAccent, size: 16),
                  );
                }
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _colorTarjetas.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(rubro['nombre'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: _colorTextoPrincipal)),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_rounded,
                                    color:
                                        _colorBotonesYDetalles.withOpacity(0.7),
                                    size: 16),
                                onPressed: () => _abrirEdicionRubro(index),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text('₡${_formatearMontoVista(progreso)}',
                                  style: TextStyle(
                                      color: colorMonto,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              iconoEstado,
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ref. Mes: ₡${_formatearMontoVista(metaMensual)} (Q: ₡${_formatearMontoVista(quincenalRef)})',
                            style: TextStyle(
                                color: _colorTextoPrincipal.withOpacity(0.6),
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.green.withOpacity(0.15)),
                          icon: const Icon(Icons.add_rounded,
                              color: Colors.green),
                          onPressed: () => _abrirOperacionSobre(index, true),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.15)),
                          icon: const Icon(Icons.remove_rounded,
                              color: Colors.redAccent),
                          onPressed: () => _abrirOperacionSobre(index, false),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.grey, size: 18),
                          onPressed: () => _eliminarRubro(index),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _construirVistaReporteria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: _colorTarjetas.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8)),
            child: Text('HISTORIAL DE MOVIMIENTOS RECIENTES',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: _colorBotonesYDetalles)),
          ),
        ),
        Expanded(
          child: historialReportes.isEmpty
              ? Center(
                  child: Text('No hay movimientos registrados aún.',
                      style: TextStyle(
                          color: _colorTextoPrincipal.withOpacity(0.6))))
              : ListView.builder(
                  itemCount: historialReportes.length,
                  itemBuilder: (context, index) {
                    final reporte = historialReportes[index];
                    bool esIngreso = reporte['tipo'] == 'INGRESO';

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _colorTarjetas.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reporte['rubro'],
                                  style: TextStyle(
                                      color: _colorTextoPrincipal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(reporte['fecha'],
                                  style: TextStyle(
                                      color:
                                          _colorTextoPrincipal.withOpacity(0.5),
                                      fontSize: 11)),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                esIngreso
                                    ? '+ ₡${_formatearMontoVista(reporte['monto'])}'
                                    : '- ₡${_formatearMontoVista(reporte['monto'])}',
                                style: TextStyle(
                                  color: esIngreso
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                esIngreso
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                color: esIngreso
                                    ? Colors.greenAccent.withOpacity(0.5)
                                    : Colors.redAccent.withOpacity(0.5),
                                size: 16,
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
