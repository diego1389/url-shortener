### Functional requirements:

Drive us to User Stories.
- URL creation and shortening: allow authors to create short URLs by inputting a full URL.
- Link management: Enable authors to view their short URLS.
- Unique URL generation: ensure each short URL generated is unique to avoid conflicts.
- User authentication: retrict access to our teams.
- Redirection: redirect short url to long URLs.

### Non-functional requirements:

- Scalability: support growing demand, initially handling thousands of links and scaling to support significantly more as clients join.
- Reliability and uptime: minimize downtime, implement robust error handling.
- Performance.
- Cost efficiency.
- User friendly interface.
- Maintainability: codebase and infrastructure should evolve easily with updates and future enhacements.

## System design

- How many urls generated per second?
- Read / write ratio?
- To determine the short url lenght is going to be 62^7 (a-z, A-Z, 0-9) this will give us 3.5 trillion possible urls which is fine because we want to be able to generate 1000 urls per second.