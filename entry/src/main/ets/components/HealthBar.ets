@Component
export struct HealthBar {
  @Prop currentHp: number;
  @Prop maxHp: number;
  @Prop name: string;
  @Prop barPosition: 'top' | 'bottom' = 'top';

  build() {
    Column() {
      Text(this.name)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .margin({ bottom: 4 })

      Stack() {
        // 血条背景
        Rect()
          .width(200)
          .height(20)
          .fill('#333333')

        // 当前血量
        Rect()
          .width(200 * (this.currentHp / this.maxHp))
          .height(20)
          .fill(this.currentHp > this.maxHp * 0.3 ? '#FF0000' : '#FF6600')

        // 血量文字
        Text(`${this.currentHp}/${this.maxHp}`)
          .fontSize(12)
          .fontColor('#FFFFFF')
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
    .alignItems(this.barPosition === 'top' ? HorizontalAlign.Start : HorizontalAlign.End)
  }
}
