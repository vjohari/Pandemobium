//
//  DBHelper.m
//  Pandemobium
//
//  Created by Adrian Salazar on 7/5/13.
//  Copyright (c) 2013 Thomas Salazar. All rights reserved.
//

#import "DBHelper.h"

@implementation DBHelper


-(NSNumber *) getAccountID:(NSNumber *) userID
{
 
    NSError *error;
    NSString *query = [[NSString alloc]initWithFormat:@"Select accountID from account where userID=%i", [userID intValue]];
    NSString *url = [[NSString alloc]initWithFormat:@"http://localhost:8080/account.jsp?query=%@", query];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSDictionary * firstParse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSArray *secondParse = [firstParse objectForKey:@"Results"];
    NSDictionary *results = [secondParse objectAtIndex:0];
    
    return [results valueForKey:@"accountID"];
}

-(NSDictionary *) logIn:(NSString *)username forPassword:(NSString *)password;
{
    NSError *error;
    NSLog(@"made it here");
    
    NSString *url = [[NSString alloc]initWithFormat:@"http://localhost:8080/user.jsp?method=logIn&username=%@&password=%@", username, password];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSDictionary * firstParse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSArray *secondParse = [firstParse objectForKey:@"Results"];
    return [secondParse objectAtIndex:0];

}

-(NSArray *) getFavoriteStocks:(NSNumber *)accountID
{
    NSError *error;
 //   NSString *query = [[NSString alloc]initWithFormat:@"Select symbol from stock where favorite=1 AND accountID=%i;", [accountID intValue]];
    NSString *query = [[NSString alloc]initWithFormat:@"Select symbol from stock where favorite=1 AND accountID=1;"];
    
    NSString *url = [[NSString alloc]initWithFormat:@"http://localhost:8080/account.jsp?query=%@", query];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSDictionary * firstParse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    return [firstParse objectForKey:@"Results"];
    
}

-(NSArray *) getPurchasedStocks:(NSNumber *)accountID
{
    NSError *error;
    //   NSString *query = [[NSString alloc]initWithFormat:@"Select symbol from stock where accountID=%i;", [accountID intValue]];
    NSString *query = [[NSString alloc]initWithFormat:@"Select * from stock where accountID=1 AND shares > 0;"];
    
    NSString *url = [[NSString alloc]initWithFormat:@"http://localhost:8080/account.jsp?query=%@", query];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSDictionary * firstParse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    return [firstParse objectForKey:@"Results"];
    
}

-(NSArray *) getAllUserStocks:(NSNumber *)accountID
{
    NSError *error;
    //   NSString *query = [[NSString alloc]initWithFormat:@"Select symbol from stock where accountID=%i;", [accountID intValue]];
    NSString *query = [[NSString alloc]initWithFormat:@"Select * from stock where accountID=1;"];
    
    NSString *url = [[NSString alloc]initWithFormat:@"http://localhost:8080/account.jsp?query=%@", query];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSDictionary * firstParse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    return [firstParse objectForKey:@"Results"];
    
}

-(NSDictionary *) getAccountInfo:(NSNumber *) accountID
{
    
    NSError *error;
    NSString *query = [[NSString alloc]initWithFormat:@"Select * from account where accountID=%i", [accountID intValue]];
    NSString *url = [[NSString alloc]initWithFormat:@"http://localhost:8080/account.jsp?query=%@", query];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSDictionary * firstParse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSArray *secondParse = [firstParse objectForKey:@"Results"];
    return [secondParse objectAtIndex:0];

}

- (NSNumber *) getAccountValue:(NSNumber *) accountID
{
  
    NSArray * listStocks = [self getPurchasedStocks:accountID];
    NSNumber *balance = [[NSNumber alloc]initWithFloat:0.0];
    NSDictionary * stockInfo;
    
    for (int i = 0; i < [listStocks count]; i++)
    {
        stockInfo = [self fetchYahooData:[[listStocks objectAtIndex:i]valueForKey:@"symbol"]];
        NSNumber * listPrice = [[NSNumber alloc]initWithFloat:[[stockInfo valueForKey:@"LastTradePriceOnly"] floatValue]];
        NSNumber * shares = [[NSNumber alloc] initWithInt:[[[listStocks objectAtIndex:i ]valueForKey:@"shares"] intValue]];
        
        balance = [NSNumber numberWithDouble:([balance doubleValue] + ([listPrice doubleValue] * [shares intValue]))];
    }
    
    return balance;
    
    
}

-(NSDictionary *)fetchYahooData:(NSString *)symbol
{
    
    
    NSString *url = [[NSString alloc]initWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=SELECT%%20*%%20FROM%%20yahoo.finance.quote%%20WHERE%%20symbol%%3D%%27%@%%27&format=json&diagnostics=false&env=store%%3A%%2F%%2Fdatatables.org%%2Falltableswithkeys&callback=", symbol];
    
    NSError *error;
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSDictionary *query = [jsonData objectForKey:@"query"];
    NSDictionary *results = [query objectForKey:@"results"];
    return  [results objectForKey:@"quote"];
    
    
}

-(NSDictionary *) buyStock:(NSNumber *)shares forSymbol:(NSString *)symbol fromAccountID:(NSNumber *)accountID
{
    NSArray * listOfStocks = [self getAllUserStocks:accountID];
    
    NSError *error;
    NSString *query; // = [[NSString alloc]initWithFormat:@"Select * from account where accountID=%i", [accountID intValue]];
    NSString *url; // = [[NSString alloc]initWithFormat:@"http://localhost:8080/account.jsp?query=%@", query];
    NSData *responseData; // = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSDictionary *firstParse;
    
    if([listOfStocks count] == 0) // Just insert stock
    {
        query = [[NSString alloc] initWithFormat:@"INSERT INTO stock (symbol, shares, accountID) values(\"%@\", %i, %i);", symbol, [shares intValue], [accountID intValue]];
            }
    else
    { // Check to see if stock is in favorites (watching or bought)
        NSPredicate *p = [NSPredicate predicateWithFormat:@"symbol = %@", symbol];
        NSArray * matched = [listOfStocks filteredArrayUsingPredicate:p];
        if([matched count] > 0)
        { //Stock Exists
            NSNumber *currentShares = [[NSNumber alloc]initWithInt:[[[matched objectAtIndex:0]objectForKey:@"shares"] intValue]];
            NSNumber *newShares = [[NSNumber alloc]initWithInt:([currentShares intValue] + [shares intValue])];
            query = [[NSString alloc] initWithFormat:
                     @"UPDATE stock SET shares = %i WHERE accountID = %i AND symbol = \"%@\";",
                     [newShares intValue], [accountID intValue], symbol ];
        }
        else
        { //Does not exist
            query = [[NSString alloc] initWithFormat:@"INSERT INTO stock (symbol, shares, accountID) values(\"%@\", %i, %i);", symbol, [shares intValue], [accountID intValue]];
        }
    }
    url = [[NSString alloc]initWithFormat:@"http://localhost:8080/account.jsp?query=%@", query];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    firstParse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    return firstParse;
    
}


-(NSDictionary *) updateAccountBalance:(NSNumber *) accountID newBalance:(NSNumber *)balance
{
    
    NSError *error;
    NSString *query = [[NSString alloc]initWithFormat:@"update account set balance = %.2f where accountID=%i;", [balance doubleValue], [accountID intValue]];
    
    NSString *url = [[NSString alloc]initWithFormat:@"http://localhost:8080/account.jsp?query=%@", query];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSDictionary * firstParse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    return firstParse;
    
}

-(NSNumber *) getShareTotal:(NSNumber *) accountID
{
    
    NSError *error;
    NSString *query = [[NSString alloc]initWithFormat:@"Select sum(shares) from stock where accountID=%i", [accountID intValue]];
    NSString *url = [[NSString alloc]initWithFormat:@"http://localhost:8080/account.jsp?query=%@", query];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSDictionary * firstParse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSArray *secondParse = [firstParse objectForKey:@"Results"];
    return [[secondParse objectAtIndex:0] objectForKey:@"SUM(SHARES)"];
    
}

-(NSArray *) getHistory:(NSNumber *)userID
{
    NSError *error;
    NSString *query = [[NSString alloc]initWithFormat:@"Select * from history where userID=%i order by time desc;", [userID intValue]];
    
    NSString *url = [[NSString alloc]initWithFormat:@"http://localhost:8080/history.jsp?query=%@", query];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSDictionary * firstParse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    return [firstParse objectForKey:@"Results"];
    
}

-(NSArray *) getTips
{
    NSError *error;
    //   NSString *query = [[NSString alloc]initWithFormat:@"Select symbol from stock where accountID=%i;", [accountID intValue]];
    NSString *query = [[NSString alloc]initWithFormat:@"Select * from tips order by tipID desc;"];
    
    NSString *url = [[NSString alloc]initWithFormat:@"http://localhost:8080/tips.jsp?query=%@", query];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSDictionary * firstParse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    return [firstParse objectForKey:@"Results"];
    
}
@end