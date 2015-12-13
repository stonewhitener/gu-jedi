final class LineLowPassFilter implements LowPassFilter<Line> {
  // Coefficients
  private final double current;
  private final double previous;

  // Keep previous data
  private Line[] lines;

  public LineLowPassFilter(double current, double previous) {
    this.current = current;
    this.previous = previous;
    
    lines = new Line[2];
    
    for (int i = 0; i < lines.length; i++) {
      lines[i] = 
        new Line(
          new PVector(0.0, 0.0),
          new PVector(0.0, 0.0)
        );
    }
  }

  public Line getFiltered(Line line) {
    lines[0] = new Line(
      new PVector(
        (float) (current * line.start.x + previous * lines[1].start.x),
        (float) (current * line.start.y + previous * lines[1].start.y)
      ),
      new PVector(
        (float) (current * line.end.x + previous * lines[1].end.x),
        (float) (current * line.end.y + previous * lines[1].end.y)
      )
    );
    
    lines[1] = lines[0];
    
    return lines[0];
  }
}
