package com.riva.odos;


import java.io.InputStream;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableAutoConfiguration
@ComponentScan
public class Application {
    
    public static void main(String[] args) {
        start(System.in, args);
    }

    public static void start(InputStream input, String[] args) {
        ApplicationContext ctx = SpringApplication.run(Application.class, args);
    }

}
