#  Order Delivery Simulator

This program simulates a food order delivery system with a non-trival shelf storage algorithm.
Solved the Reader/Writer problem with regards to the ordersDict held by each Shelf through the use of a sequential queue.

Just run from Xcode and make adjustments to the simulator constants (orderCreationRate, deliveryTimeRange, and ShelfCapacities).
Can control verbose debugging from the application window.  This was useful when app wouldn't finish because moved orders never fired their deliveryTimer.  
Otherwise, I like one debug line per order transaction (placeOrder, deliverOrder, moveOrder, and discardOrder).

If the preferred shelf is full, the order is placed on the overflow shelf.  If overflow is full then an attempt is made to move an existing order back to it's approprate shelf to make space.  If that can't happen then the order with the lowest food value is discarded (and its courier canceled) to make room for the new order on the overflow shelf.  All 'moves' and 'discards' are performed from the overflow shelf.
A check is made when the deliveryTimer fires to insure that the food value > 0, otherwise, order is discarded.

I like to run the simulation with fast input rate to insure plenty of move and discard operations and also for the simulation to run to completion quickly.

 tricky move operation details:
    If an order is moved (which only happens if it gets moved off the overflow shelf while waiting for delivery) the food value will use the new shelf's decayModifier value even though it 'decayed' at a different (higher) rate before.
    Solution: Calculate the decay up to the point of the move and subtract that from the original shelfLife.  Use new shelfLife value in future food value calculations.  
    Also, update deliveryTimer with new (shorter) deliveryTime and update the ivar 'time' with the current time

I really enjoyed doing this project.  I hope I didn't miss anything important.
If there is anything that you didn't like, please do let me know.

Best regards,

Matthew Homer


Changes from version 1
    changed Order.temperature to .temp to conform to the JSON data (when I see 'temp' I think 'temporary')
    removed Courier.shelf as ivar shelf is already in Order
    removed purgeShelf() and purgeAllOldOrders()
    changed overflow shelf discard algorithm from find and discard order with min food value to random as per spec
    replaced call to exit() with call to NSApp.terminate()
    add ivar totalOrdersMoved
    switched from using orderOperationQueue to using semaphore to protect ordersDict data
