import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  static const List<Map<String, dynamic>> adhkarAfterPrayer = [
    {
      'dhikr': 'أستغفر الله',
      'count': 3,
      'countText': '٣ مرات',
      'virtue': 'طلب المغفرة من الله',
    },
    {
      'dhikr': 'اللهم أنت السلام ومنك السلام تباركت يا ذا الجلال والإكرام',
      'count': 1,
      'countText': 'مرة واحدة',
      'virtue': 'من السنة بعد التسليم',
    },
    {
      'dhikr':
          'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير',
      'count': 10,
      'countText': '١٠ مرات',
      'virtue': 'كُتب له عشر حسنات ومُحي عنه عشر سيئات',
    },
    {
      'dhikr': 'سبحان الله',
      'count': 33,
      'countText': '٣٣ مرة',
      'virtue': 'التسبيحات الثلاث',
    },
    {
      'dhikr': 'الحمد لله',
      'count': 33,
      'countText': '٣٣ مرة',
      'virtue': 'التسبيحات الثلاث',
    },
    {
      'dhikr': 'الله أكبر',
      'count': 33,
      'countText': '٣٣ مرة',
      'virtue': 'التسبيحات الثلاث',
    },
    {
      'dhikr':
          'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير',
      'count': 1,
      'countText': 'مرة (لتمام المائة)',
      'virtue': 'تمام التسبيحات',
    },
    {
      'dhikr': 'آية الكرسي',
      'count': 1,
      'countText': 'مرة واحدة',
      'virtue': 'من قرأها دبر كل صلاة لم يمنعه من دخول الجنة إلا الموت',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أذكار ما بعد الصلاة'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: adhkarAfterPrayer.length,
        itemBuilder: (context, index) {
          final dhikr = adhkarAfterPrayer[index];
          return _AdhkarCard(
            dhikr: dhikr['dhikr'] as String,
            count: dhikr['count'] as int,
            countText: dhikr['countText'] as String,
            virtue: dhikr['virtue'] as String,
            index: index + 1,
          );
        },
      ),
    );
  }
}

class _AdhkarCard extends StatefulWidget {
  final String dhikr;
  final int count;
  final String countText;
  final String virtue;
  final int index;

  const _AdhkarCard({
    required this.dhikr,
    required this.count,
    required this.countText,
    required this.virtue,
    required this.index,
  });

  @override
  State<_AdhkarCard> createState() => _AdhkarCardState();
}

class _AdhkarCardState extends State<_AdhkarCard> {
  int _currentCount = 0;
  bool _completed = false;

  void _increment() {
    if (_currentCount < widget.count) {
      setState(() {
        _currentCount++;
        if (_currentCount >= widget.count) {
          _completed = true;
        }
      });
    }
  }

  void _reset() {
    setState(() {
      _currentCount = 0;
      _completed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: _completed ? 0 : 2,
      color: _completed ? Colors.green.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _completed ? Colors.green : Colors.transparent,
          width: _completed ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: _increment,
        onLongPress: _reset,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رقم الذكر والعدد
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _completed ? Colors.green : AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _completed
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : Text(
                              '${widget.index}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.countText,
                    style: TextStyle(
                      color: _completed ? Colors.green : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  // العداد
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _completed
                          ? Colors.green.shade100
                          : AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_currentCount / ${widget.count}',
                      style: TextStyle(
                        color:
                            _completed ? Colors.green : AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // نص الذكر
              Text(
                widget.dhikr,
                style: TextStyle(
                  fontSize: widget.dhikr.length > 50 ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: _completed ? Colors.green.shade800 : Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              // الفضل
              Text(
                widget.virtue,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
