## DNS Pod Fork

This fork is made for lego of [tencentcloud/dnspod](https://github.com/TencentCloud/tencentcloud-sdk-go/tree/master/tencentcloud/dnspod), and contains no other changes to the original code than the module name and method signatures.

This is a special fork: the methods of the structure `Client` are converted to functions which use `Client` as a parameter.

The goal is to break the link between the `Client` structure and the other structures to reduce the binary size.

This automatic approach for the fork is possible because the `tencentcloud-sdk-go` is 100 % generated.

**This fork is not intended for use outside of lego, and it can be deleted/archived at any time.**

The code of the module is inside the branch [`modifiedclient`](https://github.com/go-acme/tencentclouddnspod/tree/modifiedclient).

### Maintenance

The script to update the fork is `update.sh`.

The env var `LIB_VERSION` must be updated to reference the targeted version.

I update the branch "manually" by calling the script regularly.
