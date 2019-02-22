package com.urfu;

import java.net.URL;

public class Main {

    public static void main(String[] args) throws Exception {
        long l = System.currentTimeMillis();
        Crawler.Crawle(new URL(args[0]), Integer.parseInt(args[2]), Integer.parseInt(args[1]), args[3]);
        System.out.println(System.currentTimeMillis() - l);
    }
}
