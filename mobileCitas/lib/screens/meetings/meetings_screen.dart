import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../../core/storage/session_manager.dart';
import '../../models/meeting.dart';
import '/core/services/meeting_service.dart';

import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';
import '../../widgets/meeting/meeting_card.dart';
import 'create_meeting_screen.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  final MeetingService _meetingService = MeetingService();
  final TextEditingController _searchController = TextEditingController();

  List<Meeting> _allMeetings = [];
  List<Meeting> _filteredAllMeetings = [];
  
  List<Meeting> _myMeetings = [];
  List<Meeting> _filteredMyMeetings = [];
  
  bool _isLoading = true;
  String? _errorMessage;
  bool _puedeCrear = false;

  @override
  void initState() {
    super.initState();
    _cargarPermiso();
    _loadMeetings();
    _searchController.addListener(_applyFilter);
  }

  void _cargarPermiso() {
    final puede = SessionManager.puedeGestionarEventos;
    if (mounted) setState(() => _puedeCrear = puede);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  int _sortMeetings(Meeting a, Meeting b) {
    final weightA = a.status == MeetingStatus.finished ? 1 : 0;
    final weightB = b.status == MeetingStatus.finished ? 1 : 0;
    
    if (weightA != weightB) {
      return weightA.compareTo(weightB);
    }
    
    if (weightA == 0) {
      return a.dateTime.compareTo(b.dateTime);
    } else {
      return b.dateTime.compareTo(a.dateTime);
    }
  }

  Future<void> _loadMeetings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Meeting> all = [];
      List<Meeting> my = [];

      if (_puedeCrear) {
        all = await _meetingService.getMeetings();
        all.sort(_sortMeetings);
      }
      
      my = await _meetingService.getMisEventos();
      my.sort(_sortMeetings);

      if (!mounted) return;
      setState(() {
        _allMeetings = all;
        _filteredAllMeetings = all;
        _myMeetings = my;
        _filteredMyMeetings = my;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredAllMeetings = _allMeetings;
        _filteredMyMeetings = _myMeetings;
      } else {
        _filteredAllMeetings = _allMeetings.where((m) {
          return m.title.toLowerCase().contains(query) ||
                 m.location.toLowerCase().contains(query);
        }).toList();
        
        _filteredMyMeetings = _myMeetings.where((m) {
          return m.title.toLowerCase().contains(query) ||
                 m.location.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _goToCreateMeeting() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateMeetingScreen(),
      ),
    );

    if (created == true) {
      _loadMeetings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Reuniones",
                style: AppTextStyles.pageTitle,
              ),
              if (_puedeCrear)
                SizedBox(
                  width: 180,
                  child: AppButton(
                    text: "Crear reunión",
                    onPressed: _goToCreateMeeting,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            controller: _searchController,
            label: "Buscar reunión",
            prefixIcon: Icons.search,
          ),

          if (_puedeCrear) ...[
            const SizedBox(height: AppSpacing.md),
            const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: "Todas"),
                Tab(text: "Mis reuniones"),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: AppSpacing.md),
            Text(_errorMessage!, style: AppTextStyles.body, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: "Reintentar",
              onPressed: _loadMeetings,
            ),
          ],
        ),
      );
    }

    if (_puedeCrear) {
      return TabBarView(
        children: [
          _buildMeetingList(_filteredAllMeetings),
          _buildMeetingList(_filteredMyMeetings),
        ],
      );
    } else {
      return _buildMeetingList(_filteredMyMeetings);
    }
  }

  Widget _buildMeetingList(List<Meeting> meetings) {
    if (meetings.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadMeetings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      "No hay reuniones para mostrar",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMeetings,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: meetings.length,
        itemBuilder: (context, index) {
          final meeting = meetings[index];
          return MeetingCard(
            meeting: meeting, 
            onChanged: _loadMeetings,
          );
        },
      ),
    );
  }
}