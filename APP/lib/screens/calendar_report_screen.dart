import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class CalendarReportScreen extends StatefulWidget {
  const CalendarReportScreen({super.key});

  @override
  State<CalendarReportScreen> createState() => _CalendarReportScreenState();
}

class _CalendarReportScreenState extends State<CalendarReportScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solicitar Relatório',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Instruções
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Como solicitar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Para um dia específico: toque na data\n• Para um período: toque em "Período" e selecione início e fim',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Botões de modo de seleção
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _rangeSelectionMode = RangeSelectionMode.toggledOff;
                        _rangeStart = null;
                        _rangeEnd = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _rangeSelectionMode == RangeSelectionMode.toggledOff 
                          ? Colors.blue 
                          : const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Dia único'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _rangeSelectionMode = RangeSelectionMode.toggledOn;
                        _selectedDay = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _rangeSelectionMode == RangeSelectionMode.toggledOn 
                          ? Colors.blue 
                          : const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Período'),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // Calendário
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: TableCalendar<DateTime>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.now(),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                rangeSelectionMode: _rangeSelectionMode,
                eventLoader: (day) => [],
                
                // Dias selecionados
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                
                // Range selecionado
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                
                // Callbacks
                onDaySelected: _rangeSelectionMode == RangeSelectionMode.toggledOff 
                    ? (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _rangeStart = null;
                            _rangeEnd = null;
                          });
                        }
                      }
                    : null,
                
                onRangeSelected: _rangeSelectionMode == RangeSelectionMode.toggledOn 
                    ? (start, end, focusedDay) {
                        setState(() {
                          _selectedDay = null;
                          _focusedDay = focusedDay;
                          _rangeStart = start;
                          _rangeEnd = end;
                        });
                      }
                    : null,

                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },

                // Estilo
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: const TextStyle(color: Colors.white70),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  todayTextStyle: const TextStyle(color: Colors.white),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                  todayDecoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  rangeStartDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  rangeEndDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  withinRangeDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  rangeHighlightColor: Colors.blue,
                ),
                
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
                
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white70),
                  weekendStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),

          // Informações da seleção
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seleção atual:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getSelectionText(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Botão solicitar
          Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canRequestReport() ? _requestReport : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Solicitar Relatório',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSelectionText() {
    if (_rangeSelectionMode == RangeSelectionMode.toggledOff) {
      if (_selectedDay != null) {
        return 'Dia: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}';
      }
      return 'Nenhum dia selecionado';
    } else {
      if (_rangeStart != null && _rangeEnd != null) {
        return 'Período: ${_rangeStart!.day}/${_rangeStart!.month}/${_rangeStart!.year} até ${_rangeEnd!.day}/${_rangeEnd!.month}/${_rangeEnd!.year}';
      } else if (_rangeStart != null) {
        return 'Início: ${_rangeStart!.day}/${_rangeStart!.month}/${_rangeStart!.year} (selecione o fim)';
      }
      return 'Nenhum período selecionado';
    }
  }

  bool _canRequestReport() {
    if (_rangeSelectionMode == RangeSelectionMode.toggledOff) {
      return _selectedDay != null;
    } else {
      return _rangeStart != null && _rangeEnd != null;
    }
  }

  Future<void> _requestReport() async {
    if (!_canRequestReport()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cnpj = authProvider.currentUser?.cnpj;
      final token = authProvider.token;

      if (cnpj == null) {
        throw Exception('Usuário não autenticado');
      }

      DateTime dataInicio;
      DateTime dataFim;
      String tipoPeriodo;

      if (_rangeSelectionMode == RangeSelectionMode.toggledOff) {
        dataInicio = _selectedDay!;
        dataFim = _selectedDay!;
        tipoPeriodo = 'dia_unico';
      } else {
        dataInicio = _rangeStart!;
        dataFim = _rangeEnd!;
        tipoPeriodo = 'intervalo';
      }

      final success = await ApiService.solicitarRelatorio(
        cnpj: cnpj,
        token: token, // pode ser null
        dataInicio: dataInicio,
        dataFim: dataFim,
        tipoPeriodo: tipoPeriodo,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Relatório solicitado com sucesso! Aguarde o processamento.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Retorna true para indicar que houve solicitação
        }
      } else {
        throw Exception('Falha ao solicitar relatório');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao solicitar relatório: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}