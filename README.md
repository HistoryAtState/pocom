# Principal Officers &amp; Chiefs of Mission

Source data for [Principal Officers &amp; Chiefs of Mission](http://history.state.gov/departmenthistory/people/principals-chiefs). 

## Build

1. Single `xar` file: Files `articles.xconf` and `issues.xconf` will only contain the index, no triggers!
    ```shell
    ant
    ```

2. DEV environment: The replication triggers for the producer server are enabled in  `articles.xconf`, `issues.xconf` and point to the dev server's replication service IP.
    ```shell
    ant xar-dev
    ```

3. PROD environment: Same as in 2. but for PROD destination
    ```shell
    ant xar-prod
    ```
