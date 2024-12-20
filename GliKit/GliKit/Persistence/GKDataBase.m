//
//  GKDataBase.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/10.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKDataBase.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "GKFileManager.h"
#import "GKAppUtils.h"

@implementation GKDataBase

@synthesize dbQueue = _dbQueue;

///浏览记录数据库单例
+ (instancetype)sharedInstance
{
    static dispatch_once_t once = 0;
    static GKDataBase *dataBase = nil;
    
    dispatch_once(&once, ^(void){
        
        dataBase = [GKDataBase new];
    });
    
    return dataBase;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        //创建数据库连接
        NSString *sqlitePath = [self sqlitePath];
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:sqlitePath];
        
        [_dbQueue inDatabase:^(FMDatabase *db){
            
#ifdef DEBUG
            db.logsErrors = YES;
#endif
            if(![db open]){
#ifdef DEBUG
                NSLog(@"不能打开数据库");
#endif
            } else {
                [self onDataBaseOpen:db];
            }
        }];
    }
    
    return self;
}

- (void)dealloc
{
    [_dbQueue close];
}

- (FMDatabaseQueue*)dbQueue
{
    return _dbQueue;
}

- (void)onDataBaseOpen:(FMDatabase *)db
{
    
}

///获取数据库地址
- (NSString*)sqlitePath
{
    NSString *docDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *sqliteDirectory = [docDirectory stringByAppendingPathComponent:@"sqlite"];
    BOOL isDir = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:sqliteDirectory isDirectory:&isDir];
    
    if(!(exist && isDir)){
        if(![fileManager createDirectoryAtPath:sqliteDirectory withIntermediateDirectories:YES attributes:nil error:nil]){
            return nil;
        }else{
            //防止iCloud备份
            [GKFileManager addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:sqliteDirectory isDirectory:YES]];
        }
    }
    
    return [sqliteDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_sqlite.db", GKAppUtils.appName]];
}


@end
