/// Database table names (must match supabase/schema.sql exactly).
class Tables {
  Tables._();
  static const users = 'users';
  static const profiles = 'profiles';
  static const communities = 'communities';
  static const communityMembers = 'community_members';
  static const posts = 'posts';
  static const comments = 'comments';
  static const reactions = 'reactions';
  static const notifications = 'notifications';
  static const marketplaceListings = 'marketplace_listings';
  static const reports = 'reports';
  static const anonymousProfiles = 'anonymous_profiles';
  static const resources = 'resources';
  static const courses = 'courses';
  static const messages = 'messages';
  static const conversations = 'conversations';
  static const auditLogs = 'audit_logs';
  static const moderators = 'moderators';
}

enum UserRole { superAdmin, moderator, member, student, lecturer, alumni }

extension UserRoleX on UserRole {
  String get value => switch (this) {
        UserRole.superAdmin => 'super_admin',
        UserRole.moderator => 'moderator',
        UserRole.member => 'member',
        UserRole.student => 'student',
        UserRole.lecturer => 'lecturer',
        UserRole.alumni => 'alumni',
      };

  String get label => switch (this) {
        UserRole.superAdmin => 'Super Admin',
        UserRole.moderator => 'Moderator',
        UserRole.member => 'Member',
        UserRole.student => 'Student',
        UserRole.lecturer => 'Lecturer',
        UserRole.alumni => 'Alumni',
      };

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => UserRole.member,
    );
  }

  bool get canModerate =>
      this == UserRole.superAdmin || this == UserRole.moderator;
  bool get isAdmin => this == UserRole.superAdmin;
}

enum PostType { discussion, question, poll, marketplace }

extension PostTypeX on PostType {
  String get value => name;
  static PostType fromString(String value) =>
      PostType.values.firstWhere((e) => e.value == value,
          orElse: () => PostType.discussion);
}

enum ReactionType { like, love, helpful, interesting, insightful }

extension ReactionTypeX on ReactionType {
  String get value => name;
  String get emoji => switch (this) {
        ReactionType.like => '👍',
        ReactionType.love => '❤️',
        ReactionType.helpful => '🙌',
        ReactionType.interesting => '🤔',
        ReactionType.insightful => '💡',
      };
  static ReactionType fromString(String value) =>
      ReactionType.values.firstWhere((e) => e.value == value,
          orElse: () => ReactionType.like);
}

enum CommunityLevel { university, faculty, department, interestGroup }

extension CommunityLevelX on CommunityLevel {
  String get value => switch (this) {
        CommunityLevel.university => 'university',
        CommunityLevel.faculty => 'faculty',
        CommunityLevel.department => 'department',
        CommunityLevel.interestGroup => 'interest_group',
      };
  static CommunityLevel fromString(String value) =>
      CommunityLevel.values.firstWhere((e) => e.value == value,
          orElse: () => CommunityLevel.interestGroup);
}

enum NotificationType { comment, mention, reaction, moderatorAction, marketplace }

enum ReportStatus { pending, reviewed, actioned, dismissed }

enum ListingCategory { books, hostels, apartments, electronics, tutoring, services }

extension ListingCategoryX on ListingCategory {
  String get value => name;
  String get label => switch (this) {
        ListingCategory.books => 'Books',
        ListingCategory.hostels => 'Hostels',
        ListingCategory.apartments => 'Apartments',
        ListingCategory.electronics => 'Electronics',
        ListingCategory.tutoring => 'Tutoring',
        ListingCategory.services => 'Services',
      };
  static ListingCategory fromString(String value) =>
      ListingCategory.values.firstWhere((e) => e.value == value,
          orElse: () => ListingCategory.services);
}
