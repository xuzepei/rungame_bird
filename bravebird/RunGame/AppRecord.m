

#import "AppRecord.h"

@implementation AppRecord

@synthesize Type,Key,UserCode,DeviceId,IsHas,UserName,TableQu,Error,Status,UserPosition,CreateTime,Position,mapLoaded;
@synthesize title;
@synthesize content;
@synthesize link;
@synthesize cancelTitle;
@synthesize sureTitle;

-(id) init
{
    if ((self = [super init])) {
        mapLoaded = NO;
    }
    return self;
}

- (void)dealloc
{
    [Type release];
    [Key release];
    [UserCode release];
	[DeviceId release];
    [IsHas release];
    [UserName release];
    [TableQu release];
    [Error release];
    [Status release];
    [UserPosition release];
    [CreateTime release];
    [title release];
    [content release];
    [link release];
	[cancelTitle release];
    [sureTitle release];
    [super dealloc];
}
//编码，当对象需要保存自身时调用
-(void)encodeWithCoder:(NSCoder*)coder{
	[coder encodeObject:self.Type forKey:@"Type"];
	[coder encodeObject:self.Key forKey:@"Key"];
	[coder encodeObject:self.UserCode forKey:@"UserCode"];
	[coder encodeObject:self.DeviceId forKey:@"DeviceId"];
	[coder encodeObject:self.IsHas forKey:@"IsHas"];
	[coder encodeObject:self.UserName forKey:@"UserName"];
    [coder encodeObject:self.TableQu forKey:@"TableQu"];
    [coder encodeObject:self.Error forKey:@"Error"];
    [coder encodeObject:self.Status forKey:@"Status"];
    [coder encodeObject:self.UserPosition forKey:@"UserPosition"];
    [coder encodeObject:self.Position forKey:@"Position"];
    [coder encodeObject:self.CreateTime forKey:@"CreateTime"];
    
    [coder encodeObject:self.title forKey:@"title"];
	[coder encodeObject:self.content forKey:@"content"];
	[coder encodeObject:self.link forKey:@"link"];
	[coder encodeObject:self.cancelTitle forKey:@"cancelTitle"];
	[coder encodeObject:self.sureTitle forKey:@"sureTitle"];
}
//解码并初始化，当对象需要加载自身时调用
-(id)initWithCoder:(NSCoder *)coder{
	if(self=[super init]){
		self.Type=[coder decodeObjectForKey:@"Type"];
		self.Key=[coder decodeObjectForKey:@"Key"];
		self.UserCode=[coder decodeObjectForKey:@"UserCode"];
		self.DeviceId=[coder decodeObjectForKey:@"DeviceId"];
		self.IsHas=[coder decodeObjectForKey:@"IsHas"];
        self.UserName=[coder decodeObjectForKey:@"UserName"];
        self.TableQu=[coder decodeObjectForKey:@"TableQu"];
        self.Error=[coder decodeObjectForKey:@"Error"];
        self.Status=[coder decodeObjectForKey:@"Status"];
        self.UserPosition=[coder decodeObjectForKey:@"UserPosition"];
        self.Position=[coder decodeObjectForKey:@"Position"];
        self.CreateTime=[coder decodeObjectForKey:@"CreateTime"];
        
        self.title=[coder decodeObjectForKey:@"title"];
		self.content=[coder decodeObjectForKey:@"content"];
		self.link=[coder decodeObjectForKey:@"link"];
		self.cancelTitle=[coder decodeObjectForKey:@"cancelTitle"];
		self.sureTitle=[coder decodeObjectForKey:@"sureTitle"];
	}
	return self;
}

-(void) printAppRecord
{
    //
}

@end

