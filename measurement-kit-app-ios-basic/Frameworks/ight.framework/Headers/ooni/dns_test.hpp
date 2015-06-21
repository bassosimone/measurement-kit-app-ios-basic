/*-
 * This file is part of Libight <https://libight.github.io/>.
 *
 * Libight is free software. See AUTHORS and LICENSE for more
 * information on the copying conditions.
 */
#ifndef IGHT_OONI_DNS_TEST_HPP
# define IGHT_OONI_DNS_TEST_HPP

#include <ight/common/pointer.hpp>

#include <ight/protocols/dns.hpp>
#include <ight/ooni/net_test.hpp>

namespace ight {
namespace ooni {
namespace dns_test {

using namespace ight::common::settings;
using namespace ight::common::pointer;

struct UnsupportedQueryType : public std::runtime_error {
  using std::runtime_error::runtime_error;
};

enum class QueryType {A, NS, MD, MF, CNAME, SOA, MB, MG, MR, NUL, WKS, PTR,
                      HINFO, MINFO, MX, TXT};
enum class QueryClass {IN, CS, CH, HS};

class DNSTest : public net_test::NetTest {
    using net_test::NetTest::NetTest;

    SharedPointer<protocols::dns::Resolver> resolver;

public:
    DNSTest(std::string input_filepath_, Settings options_) : 
      net_test::NetTest(input_filepath_, options_) {
        test_name = "dns_test";
        test_version = "0.0.1";
    };

    void query(QueryType query_type, QueryClass query_class,
        std::string query_name, std::string nameserver,
        std::function<void(protocols::dns::Response&&)>&& cb);

};

}}}
#endif
