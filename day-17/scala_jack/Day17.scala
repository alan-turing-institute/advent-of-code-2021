// nasty brute force :-D
@main def Day17() =
    val targetX = 207 to 263
    val targetY = -115 to -63

    case class Point(x: Int, y: Int, vx: Int, vy: Int)

    def step(p: Point): Point =
        val x = p.x + p.vx
        val y = p.y + p.vy
        val vx = if p.vx > 0 then
            p.vx - 1
        else if p.vx < 0 then
            p.vx + 1
        else
            0
        val vy = p.vy - 1
        Point(x, y, vx, vy)

    def inTarget(p: Point, targetX: Seq[Int], targetY: Seq[Int]): Boolean =
        targetX.contains(p.x) && targetY.contains(p.y)

    var maxVY = 0
    var count = 0
    for
        initVX <- 1 to targetX.max
        initVY <- targetY.min to List(targetY.min.abs, targetY.max.abs).max
    do
        var p = Point(0, 0, initVX, initVY)
        while
            !inTarget(p, targetX, targetY) &&
            p.x <= targetX.max &&
            p.y >= targetY.min
        do
            p = step(p)

        val success = inTarget(p, targetX, targetY)
        if success then
            count = count + 1
            if initVY > maxVY then
            maxVY = initVY
    
    println(("Part 1", maxVY * (maxVY + 1) / 2))
    println(("Part 2" , count))
