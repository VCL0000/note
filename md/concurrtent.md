


并发



原子性（一个线程完成一系列操作，避免多个线程同时修改造成数据混乱），可见性（指令重排，导致的一个线程的修改在另一个线程不可见。）

volatile，对象的可见性，不保证原子性
AtomicReference，具有原子性和可见性。
final，+对象不会被多个线程创建。以实现安全发布。
synchronized,多个对象的可见性以及多个对象的原子性。
安全发布，完全构造 所有域都是final（对象,对象状态）。对象被构建完整之前不会发布该对象。对象不会被多个线程创建导致不一致。 工厂可以确保对象的完整创建，以及相关状态的设置。

并发
P45
只读共享。（不可变对象，实时不可变对象。）线程封闭。同步。保护对象。
interrupt,该线程阻塞调用wait。。。中断状态被清除并抛出InterruptedException,InterruptibleChannel,Selector 非以上则该线程的中断状态将被设置。
interrupted，是否已中断，并清理中断状态，连续调用两次，那么第二个调用将返回false。
isInterrupted，是否中断不清理中断状态。

concurrent
CountDownLatch
CyclicBarrier
DelayQueue
PriorityBlockingQueue
ScheduledExecutor
Semaphore




java 虚拟机


内存分配
方法区(Method Area)，（类信息，常量，静态常量，运行时常量池）
堆(Heap)，（对象实例），深度过高会异常，线程过多导致的内存溢出可以通过减少栈内存换取更多线程（栈内存使用的本地方法区的内存就会少，机器内存有限的情况下）。
  线程共享
虚拟机栈(VM Stack)，栈帧中存储局部变量表（基本类型，引用类型的引用，returnAddress）等信息。栈深度不足，内存不足都会异常。
本地方法栈(Native Method Stack)，native的内存区域，一样会有异常。
程序计数器(Program Counter Register)，不会有内存异常
一个线程一份
直接内存，机器的内存，NIO中Native方法分配内存，DirecByteBuffer对象作为内存的引用进行操作。



queue

|||
-|-|-
add|增加一个元索|如果队列已满，则抛出一个IIIegaISlabEepeplian异常
remove|移除并返回队列头部的元素|如果队列为空，则抛出一个NoSuchElementException异常
element|返回队列头部的元素|如果队列为空，则抛出一个NoSuchElementException异常
offer|添加一个元素并返回true|如果队列已满，则返回false
poll|移除并返问队列头部的元素|如果队列为空，则返回null
peek|返回队列头部的元素|如果队列为空，则返回null
put|添加一个元素|如果队列满，则阻塞
take|移除并返回队列头部的元素|如果队列为空，则阻塞
