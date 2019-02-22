package com.urfu;

import java.util.concurrent.Semaphore;
import java.util.concurrent.ThreadLocalRandom;
import java.util.function.Consumer;

public class Philosopher {

    private final Fork left;
    private final Fork right;
    private final int eatTime;
    private final int thinkTime;
    private final int position;
    private final ThreadLocalRandom random = ThreadLocalRandom.current();
    private final Semaphore semaphore;
    private boolean enableLogging;
    private long startWait;
    private int eatCount = 0;
    private long waitTime = 0;

    public Philosopher(int position, Fork left, Fork right, int eatTime, int thinkTime, Semaphore semaphore, boolean enableLogging) {
        this.position = position;
        this.left = left;
        this.right = right;
        this.eatTime = eatTime;
        this.thinkTime = thinkTime;
        this.semaphore = semaphore;
        this.enableLogging = enableLogging;
    }

    public void StartWorking(long eatTime) {
        long stopIn = System.currentTimeMillis() + eatTime;
        Consumer<Fork> logTookFork = fork -> Log("[Philosopher " + position + "] took " + (fork == left ? "left" : "right") +  " fork");
        while (System.currentTimeMillis() < stopIn) {
            think();
            try {
                semaphore.acquire();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            synchronized (left) {
                logTookFork.accept(left);
                synchronized (right) {
                    logTookFork.accept(right);
                    eat();
                }
            }
            semaphore.release();
        }
    }

    public int getEatCount() {
        return eatCount;
    }

    private void eat() {
        waitTime += System.currentTimeMillis() - startWait;
        Log("[Philosopher " + position + "] is eating");
        Sleep(eatTime);
        eatCount++;
        Log("[Philosopher " + position + "] finished eating");
    }

    private void think() {
        Log("[Philosopher " + position + "] is thinking");
        Sleep(thinkTime);
        Log("[Philosopher " + position + "] is hungry");
        startWait = System.currentTimeMillis();
    }

    @Override
    public String toString() {
        return "[Philosopher " + position + "] ate " + eatCount + " times and waited " + waitTime + " ms";
    }

    private void Sleep(int sleepTime) {
        try {
            Thread.sleep(random.nextInt(0, sleepTime));
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    private void Log(String message) {
        if (enableLogging)
            System.out.println(message);
    }

}
