package com.ssl.server;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/hello")
    public String hello(Authentication authentication) {
        if (authentication != null) {
            return "\"" + "Principal: " + authentication.getName() +
                    ", Authorities: " + authentication.getAuthorities() + "\"";
        }
        return "\"No Authentication\"";
    }
}
