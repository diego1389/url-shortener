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

Github. GIT for repository and Github pipelines for the CI/CD
Github actions.

- Github environments in the settings tab (Dev, testing/staging, prod).
-  Create new env -> Environment secrets -> Env variables. The difference between a secret and a variable is the accessibility. 
```
dotnet new list
dotnet new webapi
dotnet new solution
dotnet new sln --name UrlShortener
dotnet sln add Api/Api.csproj --solution-folder Api
```

Create a Github action (CI)
 * Create a workflow.
 * Steps 
 * Create a new action and search for the .NET template. Select that one.
 * The actions will be stored in .github/workflows folder.
 * Job main task (has several steps)
  - Jobs can run in parallel or in sequence. 

API.yml
```yml

# This workflow will build a .NET project
# For more information see: https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-net

name: API

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 8.0.x
    - name: Restore dependencies
      run: dotnet restore
    - name: Build
      run: dotnet build --no-restore
    - name: Test
      run: dotnet test --no-build --verbosity normal

```