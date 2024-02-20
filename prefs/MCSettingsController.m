#import "MCSettingsController.h"
#import "Preferences.h"
#import <rootless.h>
#import <spawn.h>
extern char **environ;

@implementation MCSettingsController

- (void)respring {
	// kill PostBoard too
	pid_t pid;
	const char *argv[] = {ROOT_PATH("/usr/bin/killall"), "-9", "PosterBoard", NULL};
	posix_spawn(&pid, argv[0], NULL, NULL, (char* const*)argv, environ);
	waitpid(pid, NULL, WEXITED);

	// respring
	SBSRelaunchAction *restartAction = [NSClassFromString(@"SBSRelaunchAction") actionWithReason:@"RestartRenderServer" options:SBSRelaunchOptionsFadeToBlack targetURL:[NSURL URLWithString:@"prefs:root=MoreComplications"]];
	NSSet *actions = [NSSet setWithObject:restartAction];
	FBSSystemService *frontBoardService = [NSClassFromString(@"FBSSystemService") sharedService];
	[frontBoardService sendActions:actions withResult:nil];
}

@end
