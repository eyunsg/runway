export class GetProfileResponseDto {
  email: string;
  displayName: string;

  constructor(email: string, displayName: string) {
    this.email = email;
    this.displayName = displayName;
  }
}
