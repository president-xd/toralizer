/*
    Toralizer
*/

#include "toralize.h"

/*
1. TURN THE CLIENT INTO A LIB (SHARED LIBRARY) .SO
2. TURN MAIN() INTO OUR OWN CONNECT()
3. REPLACE REGULAR CONNECT()
4. GRAB THE IP AND PORT FROM ORIG CONNECT()
5. DOING WHAT WE DO NOW
*/

Req* request(struct sockaddr_in *sock2) {
    Req* req;
    req = malloc(reqsize);
    if (!req) {
        fprintf(stderr, "Memory allocation failed for proxy request.\n");
        return NULL;
    }
    req->vn = 4;
    req->cd = 1;
    req->dstport = sock2->sin_port;
    req->dstip = sock2->sin_addr.s_addr;
    strncpy(req->userid, USERNAME, 8);
    return req;
}

int connect(int s2, const struct sockaddr *sock2, socklen_t addrlen) {
    int s;
    struct sockaddr_in sock;
    Req* req = NULL;
    Res* res = NULL;
    char buf[ressize];
    int success;
    int (*p)(int, const struct sockaddr *, socklen_t);

    // Resolve the original connect function
    p = (int (*)(int, const struct sockaddr *, socklen_t))dlsym(RTLD_NEXT, "connect");
    if (!p) {
        fprintf(stderr, "Error resolving original connect function: %s\n", dlerror());
        return -1;
    }

    // Create a socket for proxy connection
    s = socket(AF_INET, SOCK_STREAM, 0);
    if (s < 0) {
        perror("socket");
        return -1;
    }

    // Set up proxy address
    sock.sin_family = AF_INET;
    sock.sin_port = htons(PROXYPORT);
    sock.sin_addr.s_addr = inet_addr(PROXY);

    // Connect to the proxy server
    if (p(s, (struct sockaddr *)&sock, sizeof(sock)) < 0) {
        perror("connect");
        close(s);
        return -1;
    }

    printf("Connected to Proxy\n");

    // Prepare the proxy request
    req = request((struct sockaddr_in*)sock2);
    if (!req) {
        close(s);
        return -1;
    }

    // Send the request to the proxy
    if (write(s, req, reqsize) != reqsize) {
        perror("write");
        free(req);
        close(s);
        return -1;
    }

    // Receive the response from the proxy
    memset(buf, 0, ressize);
    if (read(s, buf, ressize) < 1) {
        perror("read");
        free(req);
        close(s);
        return -1;
    }

    res = (Res*)buf;
    success = (res->cd == 90);

    if (!success) {
        fprintf(stderr, "Unable to traverse the proxy, error code: %d\n", res->cd);
        free(req);
        close(s);
        return -1;
    }

    printf("Connected through the proxy.\n");

    // Duplicate the proxy socket onto the original file descriptor
    if (dup2(s, s2) < 0) {
        perror("dup2");
        free(req);
        close(s);
        return -1;
    }

    // Clean up
    free(req);
    close(s);
    return 0;
}
