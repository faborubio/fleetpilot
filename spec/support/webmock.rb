require "webmock/rspec"

# Block all external HTTP in tests; Cuprite needs localhost to drive Chrome.
WebMock.disable_net_connect!(allow_localhost: true)
