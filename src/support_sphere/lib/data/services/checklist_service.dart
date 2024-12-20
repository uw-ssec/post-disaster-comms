import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/utils/supabase.dart';

class ChecklistService {
  final SupabaseClient _supabaseClient = supabase;

  /// Get user's checklists (for basic users)
  Future<List<Map<String, dynamic>>> getUserChecklistsByUserId(
      String userId) async {
    final results = await _supabaseClient
        .from('user_checklists')
        .select('''
          id,
          user_profile_id,
          completed_at,
          checklists (
            id,
            title,
            description,
            notes,
            priority,
            updated_at,
            frequency (
              id,
              name,
              num_days
            ),
            checklist_steps_orders (
              id,
              priority,
              checklist_steps (
                id,
                label,
                description,
                updated_at
              ),
              checklist_steps_states (
                id,
                user_profile_id,
                is_completed
              )
            )
          )
        ''')
        .eq('user_profile_id', userId)
        .eq('checklists.checklist_steps_orders.checklist_steps_states.user_profile_id',
            userId)
        .order('priority',
            referencedTable: 'checklists.checklist_steps_orders',
            ascending: true);

    results.sort((a, b) {
      var priorityA =
          (a['checklists']['priority'] ?? '').toString().toLowerCase();
      var priorityB =
          (b['checklists']['priority'] ?? '').toString().toLowerCase();

      int getPriorityValue(String priority) {
        switch (priority) {
          case 'high':
            return 1;
          case 'medium':
            return 2;
          case 'low':
            return 3;
          default:
            return 4;
        }
      }

      return getPriorityValue(priorityA).compareTo(getPriorityValue(priorityB));
    });

    return results;
  }

  /// Get all checklists (for LEAP users)
  Future<List<Map<String, dynamic>>> getAllChecklists() async {
    return await _supabaseClient.from('checklists').select('''
          id,
          title,
          description,
          notes,
          priority,
          updated_at,
          frequency (
            id,
            name,
            num_days
          ),
          checklist_steps_orders (
            id,
            priority,
            checklist_steps (
              id,
              label,
              description,
              updated_at
            )
          )
        ''').order('title', ascending: true);
  }

  Future<void> updateStepStatus(String stepStateId, bool isCompleted) async {
    await _supabaseClient
        .from('checklist_steps_states')
        .update({'is_completed': isCompleted}).eq('id', stepStateId);
  }

  Future<bool> areAllStepsCompleted(
      String userChecklistId, String userId) async {
    final result = await _supabaseClient
        .from('user_checklists')
        .select('''
            checklists (
              checklist_steps_orders (
                checklist_steps_states (
                  id,
                  is_completed
                )
              )
            )
          )
        ''')
        .eq('id', userChecklistId)
        .eq('user_profile_id', userId)
        .eq('checklists.checklist_steps_orders.checklist_steps_states.user_profile_id',
            userId)
        .single();

    return result['checklists']['checklist_steps_orders'].every(
        (order) => order['checklist_steps_states'][0]['is_completed'] == true);
  }

  Future<void> updateChecklistCompletedAt(
      String userChecklistId, DateTime? completedAt) async {
    await _supabaseClient
        .from('user_checklists')
        .update({'completed_at': completedAt?.toIso8601String()}).eq(
            'id', userChecklistId);
  }

  Future<void> upsertChecklist(Map<String, dynamic> checklistData) async {
    await _supabaseClient.from('checklists').upsert(checklistData);
  }

  Future<void> upsertChecklistSteps(
      List<Map<String, Object?>> stepsData) async {
    await _supabaseClient.from('checklist_steps').upsert(stepsData);
  }

  Future<void> upsertChecklistStepsOrders(
      List<Map<String, Object?>> stepsOrdersData) async {
    await _supabaseClient
        .from('checklist_steps_orders')
        .upsert(stepsOrdersData);
  }

  Future<List<Map<String, dynamic>>> getFrequencies() async {
    return await _supabaseClient.from('frequency').select('''
          id,
          name,
          num_days
        ''').order('num_days', ascending: false);
  }

  Future<void> deleteChecklistSteps(String checklistId, List<String> stepIds) async {
    /// The trigger will handle the cascade deletion
    await _supabaseClient
        .from('checklist_steps')
        .delete()
        .inFilter('id', stepIds);
  }
}
