#import "FORMViewController.h"

@interface ScreeningQuestionViewController : FORMViewController


@property (strong, nonatomic) NSNumber* questionsFromSection;
@property (strong, nonatomic) NSString* JSONFilename;

- (void) setQuestionsFromSection:(NSNumber *)questionsFromSection;


@end
