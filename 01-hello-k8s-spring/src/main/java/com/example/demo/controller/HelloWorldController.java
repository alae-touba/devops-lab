package com.example.demo.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloWorldController {

    @Value("${APP_MESSAGE:Hello World}")
    private String appMessage;

    @GetMapping("/hello")
    public String hello() {
        return appMessage;
    }
}
