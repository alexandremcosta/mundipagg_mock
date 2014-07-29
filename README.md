# MundipaggMock

**Disclaimer**: This project is a WIP, use it at your own risk.

The objective of this project is to enable acceptance tests using the mundipagg-ruby gem. What it is supposed to do is to hook the Mundipagg::Gateway#SendToService method to just keep the hashes on an array so we can write acceptance tests that should only check that array.

As some more features, I'm planning to mock the response without having to specify all the response hash, just calling methods like ```MundipaggMock.accept_all```, ```MundipaggMock.reject_all```, and so on.
