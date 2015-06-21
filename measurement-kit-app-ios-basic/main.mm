// Part of MeasurementKit <https://measurement-kit.github.io/>.
// MeasurementKit is free software. See AUTHORS and LICENSE for more
// information on the copying conditions.

//
// \file main.mm
// Shows how to run both sync and async OONI tests from the main()
// of the iOS application without any GUI element interaction.
// Serves to demonstrate / verify that we can run MeasurementKit
// code on iOS devices and emulators without issues.
//

#import <UIKit/UIKit.h>

#import "ight/common/async.hpp"
#import "ight/common/log.hpp"
#import "ight/common/poller.hpp"
#import "ight/common/pointer.hpp"

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

static void do_async_dns_injection(async::Async& async) {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"hosts" ofType:@"txt"];
    const char *ppath = [path UTF8String];
    settings::Settings settings({{"nameserver", "8.8.8.8"}});
    pointer::SharedPointer<dns_injection::DNSInjection> test{
        new dns_injection::DNSInjection(ppath, settings)
    };
    test->set_log_verbose(1);
    async.run_test(test);
}

static void do_async_http_invalid_request_line(async::Async& async) {
    settings::Settings settings({{"backend", "http://www.google.com/"}});
    pointer::SharedPointer<http_invalid_request_line::HTTPInvalidRequestLine> test{
        new http_invalid_request_line::HTTPInvalidRequestLine(settings)
    };
    test->set_log_verbose(1);
    async.run_test(test);
}

static void do_async_tcp_connect(async::Async& async) {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"hosts" ofType:@"txt"];
    const char *ppath = [path UTF8String];
    settings::Settings settings({{"port", "80"}});
    pointer::SharedPointer<tcp_connect::TCPConnect> test{
        new tcp_connect::TCPConnect(ppath, settings)
    };
    test->set_log_verbose(1);
    async.run_test(test);
}

int main(int argc, char * argv[]) {
    ight_set_verbose(1);

    // Run sync (each test run only when next test completes)
    do_dns_injection();
    do_http_invalid_request_line();
    do_tcp_connect();

    // Run async (all the tests run in parallel)
    NSLog(@"*** run async... in progress ***");
    async::Async async;
    volatile bool done = false;
    async.on_empty([&done]() { done = true; });
    do_async_dns_injection(async);
    do_async_http_invalid_request_line(async);
    do_async_tcp_connect(async);
    while (!done) sleep(1);
    NSLog(@"*** run async... complete ***");
}
