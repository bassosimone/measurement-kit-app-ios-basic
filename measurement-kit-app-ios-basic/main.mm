// Part of MeasurementKit <https://measurement-kit.github.io/>.
// MeasurementKit is free software. See AUTHORS and LICENSE for more
// information on the copying conditions.

// Shows how to run blocking OONI tests from the App's main()

#import <UIKit/UIKit.h>

#import "ight/common/poller.hpp"
#import "ight/common/log.hpp"

#import "ight/ooni/dns_injection.hpp"
#import "ight/ooni/http_invalid_request_line.hpp"
#import "ight/ooni/tcp_connect.hpp"

using namespace ight::ooni;
using namespace ight::common;

static void do_dns_injection() {
    NSLog(@"*** DNSInjection... in progress ***");
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"hosts" ofType:@"txt"];
    const char *ppath = [path UTF8String];
    settings::Settings settings({
        {"nameserver", "8.8.8.8"},
    });
    dns_injection::DNSInjection test(ppath, settings);
    test.set_log_verbose(1);
    test.begin([&test]() {
        test.end([]() {
            ight_break_loop();
        });
    });
    ight_loop();
    NSLog(@"*** DNSInjection... complete ***");
}

static void do_http_invalid_request_line() {
    NSLog(@"*** HTTPInvalidRequestLine... in progress ***");
    settings::Settings settings({
        {"backend", "http://www.google.com/"},
    });
    http_invalid_request_line::HTTPInvalidRequestLine test(settings);
    test.set_log_verbose(1);
    test.begin([&test]() {
        test.end([]() {
            ight_break_loop();
        });
    });
    ight_loop();
    NSLog(@"*** HTTPInvalidRequestLine... complete ***");
}

static void do_tcp_connect() {
    NSLog(@"*** TCPConnect... in progress ***");
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"hosts" ofType:@"txt"];
    const char *ppath = [path UTF8String];
    settings::Settings settings({
        {"port", "80"},
    });
    tcp_connect::TCPConnect test(ppath, settings);
    test.set_log_verbose(1);
    test.begin([&test]() {
        test.end([]() {
            ight_break_loop();
        });
    });
    ight_loop();
    NSLog(@"*** TCPConnect... complete ***");
}

int main(int argc, char * argv[]) {
    ight_set_verbose(1);
    do_dns_injection();
    do_http_invalid_request_line();
    do_tcp_connect();
}
