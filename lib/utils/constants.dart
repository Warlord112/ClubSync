// This file will contain all constants for the application.
import 'package:flutter/material.dart';

// Colors
const Color kPrimaryColor = Color(0xFF6a0e33);
const Color kWhiteColor = Colors.white;
const Color kRedColor = Colors.red;
const MaterialColor kGreyColor = Colors.grey;

// Table Names
const String kUsersTable = 'users';
const String kClubsTable = 'clubs';
const String kClubMembersTable = 'club_members';

// Roles
const String kRoleInstructor = 'Instructor';
const String kRoleStudent = 'Student';
const String kRoleGeneral = 'general';
const String kRoleSubExecutive = 'sub-executive';
const String kRoleExecutive = 'executive';
const String kRoleAdvisor = 'advisor';

// Positions
const String kPositionMember = 'Member';
const String kPositionSubExecutive = 'Sub-Executive Member';
const String kPositionExecutive = 'Executive Member';
const String kPositionGeneral = 'Member';
const String kPositionFacultyAdvisor = 'Faculty Advisor';

// Event Details Strings
const String kUpcomingEventsTitle = 'Upcoming Events';
const String kNoUpcomingEventsText = 'No upcoming events';
// New: Ongoing Events Strings
const String kOngoingEventsTitle = 'On Going Events';
const String kNoOngoingEventsText = 'No on going events';
const String kPastEventsTitle = 'Past Events';
const String kNoPastEventsText = 'No past events';

// Club Members Strings
const String kAdvisorTitle = 'Advisor';
const String kCoAdvisorTitle = 'Co-Advisor';
const String kExecutiveBodyTitle = 'Executive Body';
const String kSubExecutiveBodyTitle = 'Sub Executive Body';
const String kGeneralMembersTitle = 'General Members';
const String kNoMembersText = 'No members yet';

// Default Image Paths
const String kDefaultProfileImagePath = 'assets/images/computer.svg';
const String kDefaultCoverImagePath = 'assets/images/sunset.svg';

// UI Strings
const String kClubDetailsTitle = 'Club Details';
const String kOurActivitiesTitle = 'Our Activities';
const String kOurAchievementsTitle = 'Our Achievements';
const String kViewProfileText = 'View Profile';
const String kPromoteToSubExecutiveText = 'Promote to Sub-Executive';
const String kPromoteToExecutiveText = 'Promote to Executive';
const String kDemoteToSubExecutiveText = 'Demote to Sub-Executive';
const String kDemoteToGeneralMemberText = 'Demote to General Member';
const String kRemoveMemberText = 'Remove Member';
const String kPromoteMemberSuccessMessage =
    'Member promoted successfully!'; // New: Success message for promotion
const String kErrorPromotingMember =
    'Error promoting member:'; // New: Error message for promotion
const String kDemoteMemberSuccessMessage =
    'Member demoted successfully!'; // New: Success message for demotion
const String kErrorDemotingMember =
    'Error demoting member:'; // New: Error message for demotion
const String kCreateNewClubTitle = 'Create New Club';
const String kClubCreatedSuccessMessage =
    'Club created successfully and you are now its Advisor!';
const String kErrorCreatingClub = 'Error creating club:';
const String kClubNameLabel = 'Club Name';
const String kClubDescriptionLabel = 'Club Description';
const String kPleaseEnterClubName = 'Please enter a club name';
const String kPleaseEnterClubDescription = 'Please enter a club description';
const String kProfilePictureLabel = 'Profile Picture';
const String kCoverPhotoLabel = 'Cover Photo';
const String kCreateClubButtonText = 'Create Club';
const String kSearchClubsHint = 'Search clubs...';
const String kSelectProfilePicture = 'Select Profile Picture';
const String kSelectCoverPhoto = 'Select Cover Photo';
const String kPermissionDeniedMessage = 'Only instructors can create clubs.';
const String kErrorFetchingClubs = 'Error fetching clubs:';
const String kAllClubsTitle = 'All Clubs';
const String kShowMyClubsOnlyText = 'Show my clubs only';
const String kNoClubsFoundText = 'No clubs found';
const String kViewClubButtonText = 'View Club';
const String kNoActivitiesFoundText = 'No activities found.';
const String kNoAchievementsFoundText = 'No achievements found.';

// Join Request related constants
const String kJoinRequestsTable = 'join_requests';
const String kStatusPending = 'pending';
const String kStatusApproved = 'approved';
const String kStatusDeclined = 'declined';
const String kJoinClubText = 'Join Club';
const String kCancelRequestText = 'Cancel Request';
const String kLoginRequiredMessage =
    'You need to be logged in to send a join request.';
const String kUserFullNameNotFound =
    'Could not retrieve your full name. Please ensure your profile is complete.';
const String kJoinRequestSentSuccess = 'Join request sent successfully!';
const String kErrorSendingJoinRequest = 'Error sending join request:';
const String kJoinRequestCancelledSuccess =
    'Join request cancelled successfully!';
const String kErrorCancellingJoinRequest = 'Error cancelling join request:';
const String kLeaveGroupText =
    'Leave Club'; // Updated: Text for leave club button
const String kLeaveClubSuccessMessage =
    'You have successfully left the club.'; // New: Success message for leaving club
const String kErrorLeavingClub =
    'Error leaving club:'; // New: Error message for leaving club

// Join Request Instructor-side UI Strings
const String kPendingJoinRequestsTitle = 'Pending Join Requests';
const String kNoPendingRequests = 'No pending join requests.';
const String kApproveButtonText = 'Approve';
const String kDeclineButtonText = 'Decline';
const String kJoinRequestApprovedSuccess =
    'Join request approved. Member added to the club.';
const String kJoinRequestDeclinedSuccess = 'Join request declined.';
const String kErrorApprovingJoinRequest = 'Error approving join request:';
const String kErrorDecliningJoinRequest = 'Error declining join request:';
const String kErrorFetchingJoinRequests = 'Error fetching join requests:';

// Edit Club Profile Page UI Strings
const String kEditClubProfileTitle = 'Edit Club Profile';
const String kErrorFetchingActivities = 'Error fetching activities:';
const String kPleaseEnterActivityTitle = 'Please enter an activity title';
const String kActivityAddedSuccessMessage = 'Activity added successfully!';
const String kErrorAddingActivity = 'Error adding activity:';
const String kActivityUpdatedSuccessMessage = 'Activity updated successfully!';
const String kErrorUpdatingActivity = 'Error updating activity:';
const String kActivityDeletedSuccessMessage = 'Activity deleted successfully!';
const String kErrorDeletingActivity = 'Error deleting activity:';
const String kErrorFetchingAchievements = 'Error fetching achievements:';
const String kPleaseEnterAchievementDetails =
    'Please enter both year and description for the achievement.';
const String kAchievementAddedSuccessMessage =
    'Achievement added successfully!';
const String kErrorAddingAchievement = 'Error adding achievement:';
const String kAchievementUpdatedSuccessMessage =
    'Achievement updated successfully!';
const String kErrorUpdatingAchievement = 'Error updating achievement:';
const String kAchievementDeletedSuccessMessage =
    'Achievement deleted successfully!';
const String kErrorDeletingAchievement = 'Error deleting achievement:';
const String kClubProfileUpdatedSuccessMessage =
    'Club profile updated successfully!';
const String kErrorUpdatingClubProfile = 'Error updating club profile:';
const String kAddActivityTitle = 'Add New Activity';
const String kActivityTitleLabel = 'Activity Title';
const String kActivityDescriptionLabel = 'Activity Description';
const String kAddActivityButtonText = 'Add Activity';
const String kAddAchievementTitle = 'Add New Achievement';
const String kAchievementYearLabel = 'Year';
const String kAchievementDescriptionLabel = 'Achievement Description';
const String kAddAchievementButtonText = 'Add Achievement';
const String kUpdateClubProfileButtonText = 'Update Club Profile';
const String kEditActivityTitle = 'Edit Activity';
const String kCancelButtonText = 'Cancel';
const String kUpdateActivityButtonText = 'Update Activity';
const String kEditAchievementTitle = 'Edit Achievement';
const String kUpdateAchievementButtonText = 'Update Achievement';

// Table Names for new schema
const String kActivitiesTable = 'activities';
const String kAchievementsTable = 'achievements';

// HomePage UI Strings
const String kHomeLabel = 'Home';
const String kAllClubsLabel = 'All Clubs';
const String kCreatePostLabel = 'Create Post';
const String kEventsLabel = 'Events';
const String kProfileLabel = 'Profile';
