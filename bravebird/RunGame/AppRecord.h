#import <UIKit/UIKit.h>

//定义一个保存xml解析数据类，该类使用了NSCoding协议
//可参考http://blog.csdn.net/perfect_promise/article/details/7696141
@interface AppRecord : NSObject<NSCoding>
{
    NSString *Type;
    NSString *Key;
    NSString *UserCode;
    NSString *DeviceId;
    
    NSString *IsHas;
    NSString *UserName;
    NSString *TableQu;
    NSString *Error;
    
    NSString *Status;
    NSString *UserPosition;
    NSString *Position;
    NSString *CreateTime;
    
    
    NSString *title;
    NSString *content;
    NSString *link;
    NSString *cancelTitle;
    NSString *sureTitle;

    BOOL mapLoaded;
}
@property (nonatomic, assign) BOOL mapLoaded;
@property (nonatomic, copy) NSString *Type;
@property (nonatomic, copy) NSString *Key;
@property (nonatomic, copy) NSString *UserCode;
@property (nonatomic, copy) NSString *DeviceId;
@property (nonatomic, copy) NSString *IsHas;
@property (nonatomic, copy) NSString *UserName;
@property (nonatomic, copy) NSString *TableQu;
@property (nonatomic, copy) NSString *Error;
@property (nonatomic, copy) NSString *Status;
@property (nonatomic, copy) NSString *UserPosition,*Position;
@property (nonatomic, copy) NSString *CreateTime;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *cancelTitle;
@property (nonatomic, copy) NSString *sureTitle;

-(void) printAppRecord;
@end