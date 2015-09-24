#import <Preferences/Preferences.h>

@interface MessagesTintPrefsListController: PSListController {
}
@end

@implementation MessagesTintPrefsListController
	- (id)specifiers {
		if(_specifiers == nil) {
			_specifiers = [[self loadSpecifiersFromPlistName:@"MessagesTintPrefs" target:self] retain];
		}
		return _specifiers;
	}
	-(void)twitter {
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=joe_merlino"]]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=joe_merlino"]];
		} else {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/joe_merlino"]];
		}
	}

	-(void)my_site {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/joemerlino/"]];
	}

	-(void)donate {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/joemerlino/"]];
	}
	-(void) sendEmail{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:merlino.giuseppe1@gmail.com?subject=MessagesTint"]];
	}
@end

// vim:ft=objc
