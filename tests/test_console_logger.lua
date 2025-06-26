-- Automated test for console_logger module in DevToolbox
-- Run with: lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/test_console_logger.lua

local EnhancedVirtualReaper = require('EnviREAment.enviREAment_core_lib.enhanced_virtual_reaper')
EnhancedVirtualReaper.create_environment()

local logger = dofile('./modules/console_logger.lua')

-- Test logging
logger.clear()
logger.log('Test message 1')
logger.log('Test message 2')

local messages = logger.get_messages()
assert(#messages == 2, 'Logger should contain 2 messages')
assert(messages[1]:find('Test message 1', 1, true), 'First message should be present')
assert(messages[2]:find('Test message 2', 1, true), 'Second message should be present')

logger.log('Console redirected')
messages = logger.get_messages()
assert(messages[3]:find('Console redirected', 1, true), 'Logger should log direct messages')

-- Test clear
logger.clear()
assert(#logger.get_messages() == 0, 'Logger should be empty after clear')

print('console_logger test passed.')
