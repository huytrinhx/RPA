### What is queue?

Queue in general computer science terms represent a data structure that is similar to a collection of items.

In specialized workflow management tools like RPA tools, queue becomes more sophisticated with more features to modify, add and delete and transparency through a more user-friendly interface called Orchestrator (UiPath) or Control Room (BluePrism). Most automation solutions rely on queue to manage and keep track of what needed to get done and what have been done. There is an old joke in my previous team that if a job request did not get added to the queue it did not exist. There are many instances that business and RPA team disconnect because the enqueue process is broken or even did not fire.

### Why good queue design matters?

Good queue design (1) maximize parallel execution, (2) traceability and (3) requires minimal outside supervision.
Also good queue designs support 3 motto of good solutions: easy to scale, easy to change and easy to maintain

### Few guiding principles in queue designs

Essentially, queue designs involves making decisions around what the right granular level for a unit of work and what data to store and update throughout the transaction trail.

* Repeatable: this means you can eventually get all the work done by repeating the same processes on a unit of work.
* Resumable: this means if something has occurred during the processing, you can resume or retry the process without loss of progress
* Indivisible: the unit of work can not be broken down further without having to change substantially the logics of the process. Signs of violation is usually a loop.

Queue Data:

* Reference: [Batch Reference]-[Transaction Reference] meaningful information to trace back the transaction to the original input source
* Sufficient: sufficient data are stored to progress to the end without going back to the source again
* Progresses (Optional): needed in multi-stage, multi-applications type of processes
* Output (Optional): needed when some responses from target application at the end of the transaction need to be recorded.

### Applications in common situations

* 1:1: one row, one record in the input source correspond to one unit of work

* 1:M: one row, one record in the input source correspond to multiple unit of work. Usually be treated as one to one, but if you do that, you violate the resumable and indivisible rule. Therefore, we need to create 1 queue item for each child level.

* 1:M (variant): sometimes, we may have to deal with resource lock meaning you can not possible process 2 children of the same parent at the same time because the target application won't allow that. Most people I know immediately opt for 2 queue designs: 1 queue for parent, 1 queue for child. Although it is reasonably good, two queue designs have it downsides. It can be confusing to support folks who may not know the child parent relationship by the look of it and don't know what to do. I have some work done using only 1 queue with a shared asset. This asset is pretty much a dictionary storing which parent is being worked on what worker and should be accessible to all workers. The downsides is it has a cold start problem which can be circumvent by random delay when you start multiple workers at the same time.

* 1:M:N: this is when you deal with multi-stage processes which the later stage of work must be done at different granular level such as group level. This means multiple M constitute 1 N. In my opinion, this is the only time when a 2 queue designs are needed. The downsides of 2 queue design are there but there are nothing else you could do.