import 'dart:math';

/// Generates anonymous aliases for the Anonymous Posting system, e.g.
/// "Anonymous_203", "Engineering_57", "LawStudent_12".
///
/// Real identity-to-alias mapping is stored server-side in the
/// `anonymous_profiles` table (per user, per community) and is only ever
/// readable by the user themselves and by system administrators via audit
/// records — never by moderators. See supabase/rls_policies.sql.
class AliasGenerator {
  AliasGenerator._();

  static const List<String> _prefixes = [
    'Anonymous',
    'Engineering',
    'LawStudent',
    'BizStudent',
    'MedStudent',
    'ArtStudent',
    'ScienceWiz',
    'CampusVoice',
    'QuietOwl',
    'NightOwl',
    'BoldPanther',
    'SilentFox',
  ];

  static String generate() {
    final random = Random.secure();
    final prefix = _prefixes[random.nextInt(_prefixes.length)];
    final number = random.nextInt(999) + 1;
    return '${prefix}_$number';
  }
}
