@Component
export struct SkillButton {
  @Prop label: string;
  @Prop onAction: () => void = () => {};
  @State isPressed: boolean = false;

  build() {
    Stack() {
      Circle()
        .width(70)
        .height(70)
        .fill(this.isPressed ? '#4A90E2' : '#2C3E50')
        .stroke('#FFFFFF')
        .strokeWidth(2)

      Text(this.label)
        .fontSize(24)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
    }
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
        this.onAction();
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
  }
}
