import java.util.*;

class LowPassFilter {
  // Coefficients
  final float CURRENT = 0.3;
  final float PREVIOUS = 0.7;

  // Keep a line position
  List<Line> line;

  public LowPassFilter() {
    line = new ArrayList<Line>(2);
    
    for (int i = 0; i < 2; i++) {
      line.add(
        new Line(
          new PVector(0.0, 0.0), // start
          new PVector(0.0, 0.0)  // end
        )
      );
    }
  }

  public Line getFiltered(PVector start, PVector end) {
    line.get(0).start.x = CURRENT * start.x + PREVIOUS * line.get(1).start.x;
    line.get(0).start.y = CURRENT * start.y + PREVIOUS * line.get(1).start.y;
    line.get(0).end.x = CURRENT * end.x + PREVIOUS * line.get(1).end.x;
    line.get(0).end.y = CURRENT * end.y + PREVIOUS * line.get(1).end.y;
    
    line.get(1).start.x = line.get(0).start.x;
    line.get(1).start.y = line.get(0).start.y;
    line.get(1).end.x = line.get(0).end.x;
    line.get(1).end.y = line.get(0).end.y;
    
    return line.get(0);
  }
}
