package com.urfu;

import java.util.concurrent.Semaphore;

public class Main {
    public static void main(String[] args) throws Exception {
        int count = Integer.parseInt(args[0]);
        int workTime = Integer.parseInt(args[1]) * 1000;
        int thinkTime = Integer.parseInt(args[2]);
        int eatTIme = Integer.parseInt(args[3]);
        boolean enableDebug = Integer.parseInt(args[4]) == 1;

        Semaphore semaphore = new Semaphore(count - 1);
        Philosopher[] phils = new Philosopher[count];

        Fork last = new Fork();
        Fork left = last;
        for (int i = 0; i < count; i++) {
            Fork right = (i == count - 1) ? last : new Fork();
            phils[i] = new Philosopher(i, left, right, eatTIme, thinkTime, semaphore, enableDebug);
            left = right;
        }

        Thread[] threads = new Thread[count];
        for (int i = 0; i < count; i++) {
            final int finalI = i;
            threads[i] = new Thread(() -> phils[finalI].StartWorking(workTime));
            threads[i].start();
        }
        for (Thread thread : threads) {
            thread.join();
        }
        int maxEat = -1;
        int minEat = Integer.MAX_VALUE;
        for (Philosopher phil : phils) {
            maxEat = Integer.max(phil.getEatCount(), maxEat);
            minEat = Integer.min(phil.getEatCount(), minEat);
            System.out.println(phil);
        }
        System.out.println("Max = " + maxEat + " Min = " + minEat + " max/min = " + maxEat/(double)minEat);
    }
}
